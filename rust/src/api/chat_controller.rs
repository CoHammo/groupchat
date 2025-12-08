use crate::{
    api::{chat_api::Api, database::Db, types::*},
    frb_generated::{RustAutoOpaque, StreamSink},
};
use flutter_rust_bridge::frb;
// use rustls::{
//     ServerConfig,
//     pki_types::{PrivateKeyDer, pem::PemObject},
// };
use std::{
    collections::HashMap,
    // fs,
    io::{BufRead, BufReader, Write},
    net::{Shutdown, TcpListener},
    // sync::Arc,
};

#[derive(Clone)]
pub enum StateChange {
    Login,
    Logout,
    Me,
    Groups,
    Group(String),
}

#[frb(opaque)]
pub struct ChatController {
    api: Option<Api>,
    db: Db,
    pub online: bool,
    pub groups_refreshed: bool,
    pub state: RustAutoOpaque<Changes>,
}

impl ChatController {
    pub async fn new(
        data_folder: String,
        meta_folder: String,
        online: bool,
    ) -> Result<Self, ChatError> {
        let mut db = Db::open(&data_folder, &meta_folder)?;
        let mut api: Option<Api> = None;
        if let Some(token) = db.get_meta("token")? {
            println!("GroupMe Token: {token}");
            let api1 = Api::new(&token)?;
            match api1.get_me().await {
                Ok(me) => {
                    api = Some(api1);
                    db.save_me(&me)?;
                }
                Err(e) => {
                    if e.message.contains("401 Unauthorized") {
                        db.clear_all()?;
                    }
                }
            }
        }
        Ok(ChatController {
            api,
            db,
            online,
            groups_refreshed: false,
            state: RustAutoOpaque::new(Changes::new()),
        })
    }

    #[frb(sync)]
    pub fn logged_in(&self) -> bool {
        return self.api.is_some();
    }

    #[frb(sync)]
    pub fn shrink_db(&mut self) -> Result<(), ChatError> {
        self.db.shrink()?;
        Ok(())
    }

    pub async fn login(&mut self) -> Result<(), ChatError> {
        // let ck = rcgen::generate_simple_self_signed(vec!["127.0.0.1".to_string()])?;
        // let pk = PrivateKeyDer::from_pem_slice(ck.signing_key.serialize_pem().as_bytes())?;
        // let config =
        //     ServerConfig::builder_with_provider(Arc::new(rustls::crypto::ring::default_provider()))
        //         .with_safe_default_protocol_versions()?
        //         .with_no_client_auth()
        //         .with_single_cert(vec![ck.cert.der().clone()], pk)?;

        let listener = TcpListener::bind("127.0.0.1:3000")?;
        let mut stream = listener.accept()?.0;
        // let mut conn = rustls::ServerConnection::new(Arc::new(config))?;
        // let mut tls_stream = rustls::Stream::new(&mut conn, &mut stream);

        let mut reader = BufReader::new(&mut stream);
        let mut line = String::new();
        reader.read_line(&mut line)?;
        // tls_stream.read_line(&mut line)?;
        let splits = line
            .splitn(4, |c| c == ' ' || c == '=')
            .collect::<Vec<&str>>();
        let token = splits.get(2).unwrap_or(&&"");
        println!("GroupMe Token: {token}");
        stream.write_all(b"HTTP/1.1 200 OK\r\n\r\nThanks").ok();
        stream.flush().ok();
        stream.shutdown(Shutdown::Both).ok();

        self.api = Some(Api::new(token)?);
        self.db.save_meta("token", token)?;
        self.db
            .save_me(&self.api.as_ref().unwrap().get_me().await?)?;
        self.state.read().await.notify(StateChange::Login)?;
        println!("Logged In");
        Ok(())
    }

    #[frb(sync)]
    pub fn logout(&mut self) -> Result<(), ChatError> {
        self.db.clear_all()?;
        self.api = None;
        self.state.blocking_read().notify(StateChange::Logout)?;
        Ok(())
    }

    pub async fn refresh_all(&mut self) -> Result<(), ChatError> {
        let _lm = self.load_me().await?;
        let _lg = self.load_groups(true).await?;
        Ok(())
    }

    pub async fn load_me(&mut self) -> Result<(), ChatError> {
        if let Some(api) = &self.api {
            let new_me = api.get_me().await?;
            let old_me = self.db.get_me()?;
            if let Some(me) = old_me {
                if me != new_me {
                    self.db.save_me(&new_me)?;
                    self.state.read().await.notify(StateChange::Me)?;
                }
            }
        }
        Ok(())
    }

    #[frb(sync)]
    pub fn get_me(&self) -> Result<Me, ChatError> {
        let me = self.db.get_me()?.unwrap_or_default();
        Ok(me)
    }

    pub async fn update_me(
        &mut self,
        mut me: Me,
        toggle_sharing: bool,
        profile_photo: Option<Vec<u8>>,
        gallery_photos: Option<Vec<(Option<Vec<u8>>, String)>>,
    ) -> Result<bool, ChatError> {
        if let Some(api) = &self.api {
            if let Some(bytes) = profile_photo {
                if let Attachment::Image { url } = api.upload_image(bytes).await? {
                    me.image_url = Some(url);
                }
            }

            if let Some(photos) = gallery_photos {
                me.photo_urls = Vec::new();
                for image in photos {
                    if let Some(bytes) = image.0 {
                        if let Attachment::Image { url } = api.upload_image(bytes).await? {
                            me.photo_urls.push(url);
                        }
                    } else {
                        me.photo_urls.push(image.1);
                    }
                }
            }

            let mut new_me = api.update_me(&me).await?;
            if toggle_sharing {
                let shares;
                if me.share_url.is_some() {
                    shares = api.toggle_sharing_me(true).await?;
                } else {
                    shares = api.toggle_sharing_me(false).await?;
                }
                new_me.share_url = shares.0;
                new_me.share_qr_code_url = shares.1;
            }

            self.db.save_me(&new_me)?;
            self.state.read().await.notify(StateChange::Me)?;
        }
        Ok(true)
    }

    pub async fn load_groups(&mut self, load_all: bool) -> Result<(), ChatError> {
        if let Some(api) = &self.api
            && self.online
        {
            if load_all {
                self.db.clear_groups()?;
                let mut page = 1;
                let mut next = true;
                let mut to_save: Vec<Group> = Vec::new();
                while next {
                    let mut groups = api.get_groups(page, 100).await?;
                    if groups.len() < 100 {
                        next = false;
                    }
                    to_save.append(&mut groups);
                    page += 1;
                }
                self.db.save_groups(&to_save)?;
                self.groups_refreshed = true;
                self.state.read().await.notify(StateChange::Groups)?;
            } else if !self.groups_refreshed {
                let mut page = 1;
                let mut next = true;
                let mut to_save: Vec<Group> = Vec::new();
                while next {
                    let updated_groups = api.get_groups(page, 10).await?;
                    for updated_group in updated_groups {
                        if let Some(old_group) = self.db.get_group(&updated_group.id)? {
                            if old_group.updated_at != updated_group.updated_at {
                                to_save.push(updated_group);
                            } else {
                                break;
                            }
                        } else {
                            to_save.push(updated_group);
                        }
                    }
                    if to_save.len() < (page * 10).try_into().unwrap() {
                        next = false;
                    } else {
                        page += 1;
                    }
                }
                self.db.save_groups(&to_save)?;
                self.groups_refreshed = true;
                self.state.read().await.notify(StateChange::Groups)?;
            }
        }
        Ok(())
    }

    #[frb(sync)]
    pub fn get_groups(&mut self) -> Result<Vec<Group>, ChatError> {
        let mut groups = self.db.get_groups()?;
        groups.sort_by_key(|group| {
            if group.last_message_created_at != 0 {
                return group.last_message_created_at;
            } else {
                return group.updated_at;
            }
        });
        groups.reverse();
        Ok(groups)
    }

    pub async fn create_group(&mut self) -> Result<(), ChatError> {
        if let Some(api) = &self.api {
            let group = api
                .create_group(
                    "Test From GroupChat",
                    Some("Made with Programming!".to_string()),
                    false,
                    "private",
                )
                .await?;
            println!("{group:#?}");
            self.db.save_groups(&vec![group])?;
            self.state.read().await.notify(StateChange::Groups)?;
            Ok(())
        } else {
            Err(ChatError::new("Not logged in", None))
        }
    }

    pub async fn get_image(&mut self, id: &str) -> Result<Vec<u8>, ChatError> {
        if let Some(image) = self.db.get_image(id)? {
            Ok(image)
        } else {
            if let Some(api) = &self.api {
                let image = api.get_image(id).await?;
                self.db.save_image(id, image.clone())?;
                Ok(image)
            } else {
                Err(ChatError::new(
                    "Controller get_image: Image not cached and not logged in",
                    None,
                ))
            }
        }
    }
}

pub struct ChangesId(pub i32);

#[frb(opaque)]
pub struct Changes {
    listeners: HashMap<i32, StreamSink<StateChange>>,
}

impl Changes {
    pub fn new() -> Self {
        return Changes {
            listeners: HashMap::new(),
        };
    }

    #[frb(sync)]
    pub fn next_id(&self) -> ChangesId {
        return ChangesId(self.listeners.len() as i32);
    }

    pub fn changes(
        &mut self,
        id: ChangesId,
        sink: StreamSink<StateChange>,
    ) -> Result<(), ChatError> {
        self.listeners.insert(id.0, sink);
        Ok(())
    }

    #[frb(sync)]
    pub fn notify(&self, change: StateChange) -> Result<(), ChatError> {
        for listener in self.listeners.values() {
            listener.add(change.clone())?;
        }
        Ok(())
    }

    #[frb(sync)]
    pub fn unlisten(&mut self, id: ChangesId) {
        self.listeners.remove(&id.0);
    }
}
