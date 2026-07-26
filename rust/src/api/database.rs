use crate::api::types::*;
use flutter_rust_bridge::frb;
use heed::{Database, Env, EnvOpenOptions, types::*};
use std::fs;

#[derive(Debug)]
#[frb(ignore)]
pub struct Db {
    meta_env: Env,
    metadata: Database<Str, DbItem<String>>,
    // meta_folder: String,
    env: Env,
    dbs: Dbs,
    data_folder: String,
    ab_version: String,
}

#[derive(Debug)]
#[frb(ignore)]
pub struct Dbs {
    me: Database<Str, DbItem<Me>>,
    users: Database<Str, DbItem<User>>,
    members: Database<Str, DbItem<Member>>,
    chats: Database<Str, DbItem<Chat>>,
    groups: Database<Str, DbItem<Group>>,
    messages: Database<Str, DbItem<Message>>,
    polls: Database<Str, DbItem<Poll>>,
    events: Database<Str, DbItem<Event>>,
    images: Database<Str, DbImage>,
}

impl Db {
    fn open_meta_env(folder: &str) -> Result<Env, ChatError> {
        let meta_env = unsafe {
            EnvOpenOptions::new()
                .map_size(1024 * 1024 * 5)
                .max_dbs(2)
                .open(&folder)?
        };
        Ok(meta_env)
    }

    fn open_env(folder: &str) -> Result<Env, ChatError> {
        let env = unsafe {
            EnvOpenOptions::new()
                .map_size(1024 * 1024 * 200)
                .max_dbs(10)
                .open(&folder)?
        };
        Ok(env)
    }

    pub fn open_dbs(env: &Env) -> Result<Dbs, ChatError> {
        let mut writer = env.write_txn()?;
        let me = env.create_database::<Str, DbItem<Me>>(&mut writer, Some("me"))?;
        let users = env.create_database::<Str, DbItem<User>>(&mut writer, Some("users"))?;
        let members = env.create_database::<Str, DbItem<Member>>(&mut writer, Some("members"))?;
        let chats = env.create_database::<Str, DbItem<Chat>>(&mut writer, Some("chats"))?;
        let groups = env.create_database::<Str, DbItem<Group>>(&mut writer, Some("groups"))?;
        let messages =
            env.create_database::<Str, DbItem<Message>>(&mut writer, Some("messages"))?;
        let polls = env.create_database::<Str, DbItem<Poll>>(&mut writer, Some("polls"))?;
        let events = env.create_database::<Str, DbItem<Event>>(&mut writer, Some("events"))?;
        let images = env.create_database::<Str, DbImage>(&mut writer, Some("images"))?;
        writer.commit()?;

        Ok(Dbs {
            me,
            users,
            members,
            chats,
            groups,
            messages,
            polls,
            events,
            images,
        })
    }

    pub fn open(data_folder: &str, meta_folder: &str) -> Result<Self, ChatError> {
        if !fs::exists(&meta_folder)? {
            fs::create_dir_all(&meta_folder)?;
        }
        let meta_env = Db::open_meta_env(meta_folder)?;
        let mut meta_writer = meta_env.write_txn()?;
        let metadata =
            meta_env.create_database::<Str, DbItem<String>>(&mut meta_writer, Some("metadata"))?;
        let full_data_folder: String;
        let ab_version: String;
        if let Some(version) = metadata.get(&meta_writer, "ab_version")? {
            ab_version = version;
            full_data_folder = format!("{data_folder}/{ab_version}");
        } else {
            ab_version = "A".to_string();
            full_data_folder = format!("{data_folder}/{ab_version}");
            metadata.put(&mut meta_writer, "ab_version", &ab_version)?;
        }
        meta_writer.commit()?;

        if !fs::exists(&full_data_folder)? {
            fs::create_dir_all(&full_data_folder)?;
        }
        println!("Database Folder: {full_data_folder}");
        let env = Db::open_env(&full_data_folder)?;
        let dbs = Db::open_dbs(&env)?;

        Ok(Db {
            meta_env,
            metadata,
            env,
            dbs,
            data_folder: data_folder.to_string(),
            // meta_folder: meta_folder.to_string(),
            ab_version,
        })
    }

    pub fn toggle_ab_version(&mut self, copy: bool) -> Result<(), ChatError> {
        let old_folder = format!("{}/{}", self.data_folder, self.ab_version);
        if self.ab_version.as_str() == "A" {
            self.ab_version = "B".to_string();
        } else {
            self.ab_version = "A".to_string();
        }
        let mut writer = self.meta_env.write_txn()?;
        self.metadata
            .put(&mut writer, "ab_version", &self.ab_version)?;
        writer.commit()?;

        let folder = format!("{}/{}", self.data_folder, self.ab_version);
        println!("New Database Folder: {folder}");
        if !fs::exists(&folder)? {
            fs::create_dir_all(&folder)?;
        }
        if copy {
            self.env.copy_to_path(
                format!("{folder}/data.mdb"),
                heed::CompactionOption::Enabled,
            )?;
        }
        self.env = Db::open_env(&folder)?;
        self.dbs = Db::open_dbs(&self.env)?;

        if fs::exists(&old_folder)? {
            fs::remove_dir_all(old_folder)?;
        }
        Ok(())
    }

    pub fn clear_cache(&mut self) -> Result<(), ChatError> {
        self.toggle_ab_version(false)?;
        Ok(())
    }

    pub fn clear_all(&mut self) -> Result<(), ChatError> {
        let mut meta_writer = self.meta_env.write_txn()?;
        self.metadata.clear(&mut meta_writer)?;
        meta_writer.commit()?;
        self.toggle_ab_version(false)?;
        Ok(())
    }

    pub fn shrink(&mut self) -> Result<(), ChatError> {
        self.toggle_ab_version(true)?;
        Ok(())
    }

    pub fn save_meta(&self, key: &str, data: &str) -> Result<(), ChatError> {
        let mut wtxn = self.meta_env.write_txn()?;
        self.metadata.put(&mut wtxn, key, &data.to_string())?;
        wtxn.commit()?;
        Ok(())
    }

    pub fn get_meta(&self, key: &str) -> Result<Option<String>, ChatError> {
        let rtxn = self.meta_env.read_txn()?;
        let token = self.metadata.get(&rtxn, key)?;
        rtxn.commit()?;
        Ok(token)
    }

    pub fn save_me(&self, me: &Me) -> Result<(), ChatError> {
        let mut wtxn = self.env.write_txn()?;
        self.dbs.me.put(&mut wtxn, "0", &me)?;
        wtxn.commit()?;
        Ok(())
    }

    pub fn get_me(&self) -> Result<Option<Me>, ChatError> {
        let rtxn = self.env.read_txn()?;
        let me = match self.dbs.me.first(&rtxn)? {
            Some(me) => Some(me.1),
            _ => None,
        };
        rtxn.commit()?;
        Ok(me)
    }

    pub fn save_users(&self, users: &Vec<User>) -> Result<(), ChatError> {
        let mut wtxn = self.env.write_txn()?;
        for user in users {
            self.dbs.users.put(&mut wtxn, &user.id, user)?;
        }
        wtxn.commit()?;
        Ok(())
    }

    pub fn get_users(&self, search: &str) -> Result<Vec<User>, ChatError> {
        let rtxn = self.env.read_txn()?;
        let mut users: Vec<User> = Vec::new();
        for u in self.dbs.users.iter(&rtxn)? {
            let user = u?.1;
            if user.name.contains(search) {
                users.push(user);
            }
        }
        rtxn.commit()?;
        Ok(users)
    }

    pub fn get_user(&self, id: &str) -> Result<Option<User>, ChatError> {
        let rtxn = self.env.read_txn()?;
        let user = self.dbs.users.get(&rtxn, id)?;
        Ok(user)
    }

    pub fn save_members(&self, members: &Vec<Member>) -> Result<(), ChatError> {
        let mut wtxn = self.env.write_txn()?;
        for member in members {
            self.dbs.members.put(&mut wtxn, &member.id, member)?;
        }
        wtxn.commit()?;
        Ok(())
    }

    pub fn get_members(&self, ids: &Vec<String>) -> Result<Vec<Member>, ChatError> {
        let rtxn = self.env.read_txn()?;
        let mut members: Vec<Member> = Vec::new();
        for id in ids {
            match self.dbs.members.get(&rtxn, &id)? {
                Some(member) => members.push(member),
                None => (),
            }
        }
        Ok(members)
    }

    pub fn save_chats(&self, chats: &Vec<Chat>) -> Result<(), ChatError> {
        let mut wtxn = self.env.write_txn()?;
        for chat in chats {
            self.dbs.chats.put(&mut wtxn, &chat.id, chat)?;
        }
        wtxn.commit()?;
        Ok(())
    }

    pub fn get_chats(&self) -> Result<Vec<Chat>, ChatError> {
        let rtxn = self.env.read_txn()?;
        let mut chats: Vec<Chat> = Vec::new();
        for c in self.dbs.chats.iter(&rtxn)? {
            let chat = c?.1;
            chats.push(chat);
        }
        Ok(chats)
    }

    pub fn save_groups(&mut self, groups: &Vec<Group>) -> Result<(), ChatError> {
        if !groups.is_empty() {
            let mut wtxn = self.env.write_txn()?;
            for group in groups {
                self.dbs.groups.put(&mut wtxn, &group.id, group)?;
            }
            wtxn.commit()?;
        }
        Ok(())
    }

    pub fn get_groups(&mut self) -> Result<Vec<Group>, ChatError> {
        let rtxn = self.env.read_txn()?;
        let mut groups: Vec<Group> = Vec::new();
        for group in self.dbs.groups.iter(&rtxn)? {
            groups.push(group?.1);
        }
        Ok(groups)
    }

    pub fn clear_groups(&mut self) -> Result<(), ChatError> {
        let mut wtxn = self.env.write_txn()?;
        self.dbs.groups.clear(&mut wtxn)?;
        wtxn.commit()?;
        Ok(())
    }

    pub fn get_group(&self, group_id: &str) -> Result<Option<Group>, ChatError> {
        let rtxn = self.env.read_txn()?;
        let group = self.dbs.groups.get(&rtxn, group_id)?;
        Ok(group)
    }

    pub fn save_messages(&self, messages: &Vec<Message>) -> Result<(), ChatError> {
        let mut wtxn = self.env.write_txn()?;
        for message in messages {
            self.dbs.messages.put(&mut wtxn, &message.id, &message)?;
        }
        wtxn.commit()?;
        Ok(())
    }

    pub fn get_messages(&self, ids: &Vec<String>) -> Result<Vec<Message>, ChatError> {
        let rtxn = self.env.read_txn()?;
        let mut messages: Vec<Message> = Vec::new();
        for id in ids {
            match self.dbs.messages.get(&rtxn, &id)? {
                Some(message) => messages.push(message),
                None => (),
            }
        }
        Ok(messages)
    }

    pub fn save_poll(&self, poll: &Poll) -> Result<(), ChatError> {
        let mut wtxn = self.env.write_txn()?;
        self.dbs.polls.put(&mut wtxn, &poll.id, poll)?;
        wtxn.commit()?;
        Ok(())
    }

    pub fn get_poll(&self, id: &str) -> Result<Option<Poll>, ChatError> {
        let rtxn = self.env.read_txn()?;
        let poll = self.dbs.polls.get(&rtxn, id)?;
        rtxn.commit()?;
        Ok(poll)
    }

    pub fn save_event(&self, event: &Event) -> Result<(), ChatError> {
        let mut wtxn = self.env.write_txn()?;
        self.dbs.events.put(&mut wtxn, &event.id, event)?;
        wtxn.commit()?;
        Ok(())
    }

    pub fn get_event(&self, id: &str) -> Result<Option<Event>, ChatError> {
        let rtxn = self.env.read_txn()?;
        let event = self.dbs.events.get(&rtxn, id)?;
        rtxn.commit()?;
        Ok(event)
    }

    pub fn save_image(&mut self, id: &str, image: Vec<u8>) -> Result<(), ChatError> {
        // self.image_map.insert(id.to_string(), image.clone());
        let mut wtxn = self.env.write_txn()?;
        self.dbs.images.put(&mut wtxn, id, &DbImage(image))?;
        wtxn.commit()?;
        Ok(())
    }

    pub fn get_image(&mut self, id: &str) -> Result<Option<Vec<u8>>, ChatError> {
        // if let Some(img) = self.image_map.get(id) {
        //     println!("Used image_map");
        //     Ok(Some(img.clone()))
        // } else {
        //     let rtxn = self.env.read_txn()?;
        //     let image = self.images.get(&rtxn, id)?;
        //     rtxn.commit()?;
        //     if let Some(img) = image {
        //         self.image_map.insert(id.to_string(), img.0.clone());
        //         Ok(Some(img.0))
        //     } else {
        //         Ok(None)
        //     }
        // }
        let rtxn = self.env.read_txn()?;
        let image = self.dbs.images.get(&rtxn, id)?;
        rtxn.commit()?;
        Ok(image.map(|i| i.0))
    }
}
