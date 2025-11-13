use std::collections::HashMap;
use std::sync::{Arc, Mutex};

use crate::{
    api::{chat_api::Api, database::Db, types::*},
    frb_generated::RustAutoOpaque,
};
use flutter_rust_bridge::frb;
use warp::Filter;

#[frb(opaque)]
pub struct ChatController {
    api: Api,
    db: Db,
    pub me: Option<RustAutoOpaque<Me>>,
    pub needs_login: bool,
}

impl ChatController {
    pub fn new(folder: String) -> Result<Self, ChatError> {
        let db = Db::open(folder)?;
        if let Some(me) = db.get_me()? {
            let api = Api::new(Some(&me.access_token))?;
            Ok(ChatController {
                api,
                db,
                me: Some(RustAutoOpaque::new(me)),
                needs_login: false,
            })
        } else {
            Ok(ChatController {
                api: Api::new(None)?,
                db,
                me: None,
                needs_login: true,
            })
        }
    }
    pub async fn login(&mut self) -> Result<(), ChatError> {
        // create a oneshot channel to receive the access token
        let (tx, rx) = tokio::sync::oneshot::channel::<String>();
        let tx = Arc::new(Mutex::new(Some(tx)));
        let received = Arc::new(Mutex::new(None));
        let received_clone = received.clone();

        // have a server listening to get the token
        let route =
            warp::query::<HashMap<String, String>>().map(move |tok: HashMap<String, String>| {
                println!("{tok:#?}");
                let access = tok.get("access_token").cloned().unwrap_or_default();
                if let Some(sender) = tx.lock().unwrap().take() {
                    let _ = sender.send(access.clone());
                }
                return format!("Thanks");
            });

        // run server and shut it down after we receive the token
        warp::serve(route)
            .bind(([127, 0, 0, 1], 3000))
            .await
            .graceful(async move {
                if let Ok(token_value) = rx.await {
                    *received_clone.lock().unwrap() = Some(token_value);
                }
            })
            .run()
            .await;

        let token = received.lock().unwrap().take().unwrap_or_default();
        self.api.login(&token)?;
        let mut me = self.api.get_me().await?;
        me.access_token = token;
        self.db.save_me(&me)?;
        self.me = Some(RustAutoOpaque::new(me));
        self.needs_login = false;
        println!("Logged In");
        Ok(())
    }
}
