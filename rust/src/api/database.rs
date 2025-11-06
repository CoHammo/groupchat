use crate::api::types::*;
use flutter_rust_bridge::frb;
use heed::{types::*, Env, EnvOpenOptions};
use std::fs;

#[frb(opaque)]
pub struct Db {
    #[frb(ignore)]
    pub env: Env,
}

impl Db {
    pub fn open(path: String) -> Result<Db, ChatError> {
        let folder = format!("{path}/GroupChatDb");
        if !fs::exists(&folder)? {
            fs::create_dir(&folder)?;
        }
        let env = unsafe { EnvOpenOptions::new().max_dbs(50).open(folder)? };
        let mut writer = env.write_txn()?;

        env.create_database::<Str, DbItem<User>>(&mut writer, Some("Users"))?;

        writer.commit()?;

        Ok(Db { env })
    }
}
