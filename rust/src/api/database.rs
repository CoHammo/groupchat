use crate::api::types::*;
use flutter_rust_bridge::frb;
use heed::{Database, Env, EnvOpenOptions, types::*};
use std::fs;

#[derive(Debug)]
#[frb(ignore)]
pub struct Db {
    meta_env: Env,
    metadata: Database<Str, DbItem<String>>,
    env: Env,
    me: Database<Str, DbItem<Me>>,
    users: Database<Str, DbItem<User>>,
    members: Database<Str, DbItem<Member>>,
    chats: Database<Str, DbItem<Chat>>,
    groups: Database<Str, DbItem<Group>>,
    messages: Database<Str, DbItem<Message>>,
    polls: Database<Str, DbItem<Poll>>,
    events: Database<Str, DbItem<Event>>,
    data_folder: String,
}

impl Db {
    pub fn open(data_folder: &str, meta_folder: &str) -> Result<Self, ChatError> {
        if !fs::exists(&meta_folder)? {
            fs::create_dir_all(&meta_folder)?;
        }
        let meta_env = unsafe {
            EnvOpenOptions::new()
                .map_size(1024 * 1024 * 5)
                .max_dbs(20)
                .open(&meta_folder)?
        };
        let mut meta_writer = meta_env.write_txn()?;
        let metadata =
            meta_env.create_database::<Str, DbItem<String>>(&mut meta_writer, Some("metadata"))?;
        let full_data_folder = match metadata.get(&meta_writer, "AB_version")? {
            Some(version) => format!("{}/{version}", data_folder),
            None => {
                let folder = format!("{data_folder}/A");
                metadata.put(&mut meta_writer, "AB_version", &"A".to_string())?;
                folder
            }
        };
        meta_writer.commit()?;

        if !fs::exists(&full_data_folder)? {
            fs::create_dir_all(&full_data_folder)?;
        }
        println!("{full_data_folder}");
        let env = unsafe {
            EnvOpenOptions::new()
                .map_size(1024 * 1024 * 200)
                .max_dbs(20)
                .open(&full_data_folder)?
        };

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
        writer.commit()?;

        Ok(Db {
            meta_env,
            metadata,
            env,
            me,
            users,
            members,
            chats,
            groups,
            messages,
            polls,
            events,
            data_folder: data_folder.to_string(),
        })
    }

    pub fn clear_cache(&self) -> Result<(), ChatError> {
        let mut wtxn = self.env.write_txn()?;
        self.me.clear(&mut wtxn)?;
        self.users.clear(&mut wtxn)?;
        self.members.clear(&mut wtxn)?;
        self.chats.clear(&mut wtxn)?;
        self.groups.clear(&mut wtxn)?;
        self.messages.clear(&mut wtxn)?;
        self.polls.clear(&mut wtxn)?;
        self.events.clear(&mut wtxn)?;
        wtxn.commit()?;
        Ok(())
    }

    pub fn clear_all(&self) -> Result<(), ChatError> {
        let mut meta_wtxn = self.meta_env.write_txn()?;
        self.metadata.clear(&mut meta_wtxn)?;
        meta_wtxn.commit()?;
        self.clear_cache()?;
        Ok(())
    }

    pub fn shrink(&mut self) -> Result<(), ChatError> {
        let data_version = self.get_meta("AB_version")?.unwrap();
        let old_data_folder: String;
        let new_data_folder: String;
        if data_version.as_str() == "A" {
            old_data_folder = format!("{}/A", self.data_folder);
            new_data_folder = format!("{}/B", self.data_folder);
        } else {
            old_data_folder = format!("{}/B", self.data_folder);
            new_data_folder = format!("{}/A", self.data_folder);
        }

        if !fs::exists(&new_data_folder)? {
            fs::create_dir_all(&new_data_folder)?;
        }
        self.env.copy_to_path(
            format!("{new_data_folder}/data.mdb"),
            heed::CompactionOption::Enabled,
        )?;
        self.env = unsafe {
            EnvOpenOptions::new()
                .map_size(1024 * 1024 * 200)
                .max_dbs(20)
                .open(&new_data_folder)?
        };
        let mut writer = self.env.write_txn()?;
        self.me = self
            .env
            .open_database::<Str, DbItem<Me>>(&mut writer, Some("me"))?
            .unwrap();
        self.users = self
            .env
            .open_database::<Str, DbItem<User>>(&mut writer, Some("users"))?
            .unwrap();
        self.members = self
            .env
            .open_database::<Str, DbItem<Member>>(&mut writer, Some("members"))?
            .unwrap();
        self.chats = self
            .env
            .open_database::<Str, DbItem<Chat>>(&mut writer, Some("chats"))?
            .unwrap();
        self.groups = self
            .env
            .open_database::<Str, DbItem<Group>>(&mut writer, Some("groups"))?
            .unwrap();
        self.messages = self
            .env
            .open_database::<Str, DbItem<Message>>(&mut writer, Some("messages"))?
            .unwrap();
        self.polls = self
            .env
            .open_database::<Str, DbItem<Poll>>(&mut writer, Some("polls"))?
            .unwrap();
        self.events = self
            .env
            .open_database::<Str, DbItem<Event>>(&mut writer, Some("events"))?
            .unwrap();
        writer.commit()?;

        if fs::exists(&old_data_folder)? {
            fs::remove_dir_all(old_data_folder)?;
        }

        if data_version.as_str() == "A" {
            self.save_meta("AB_version", "B")?;
        } else {
            self.save_meta("AB_version", "A")?;
        }

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
        self.me.put(&mut wtxn, "0", &me)?;
        wtxn.commit()?;
        Ok(())
    }

    pub fn get_me(&self) -> Result<Option<Me>, ChatError> {
        let rtxn = self.env.read_txn()?;
        let me = match self.me.first(&rtxn)? {
            Some(me) => Some(me.1),
            _ => None,
        };
        rtxn.commit()?;
        Ok(me)
    }

    pub fn save_users(&self, users: &Vec<User>) -> Result<(), ChatError> {
        let mut wtxn = self.env.write_txn()?;
        for user in users {
            self.users.put(&mut wtxn, &user.id, user)?;
        }
        wtxn.commit()?;
        Ok(())
    }

    pub fn get_users(&self, search: &str) -> Result<Vec<User>, ChatError> {
        let rtxn = self.env.read_txn()?;
        let mut users: Vec<User> = Vec::new();
        for u in self.users.iter(&rtxn)? {
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
        let user = self.users.get(&rtxn, id)?;
        Ok(user)
    }

    pub fn save_members(&self, members: &Vec<Member>) -> Result<(), ChatError> {
        let mut wtxn = self.env.write_txn()?;
        for member in members {
            self.members.put(&mut wtxn, &member.id, member)?;
        }
        wtxn.commit()?;
        Ok(())
    }

    pub fn get_members(&self, ids: &Vec<String>) -> Result<Vec<Member>, ChatError> {
        let rtxn = self.env.read_txn()?;
        let mut members: Vec<Member> = Vec::new();
        for id in ids {
            match self.members.get(&rtxn, &id)? {
                Some(member) => members.push(member),
                None => (),
            }
        }
        Ok(members)
    }

    pub fn save_chats(&self, chats: &Vec<Chat>) -> Result<(), ChatError> {
        let mut wtxn = self.env.write_txn()?;
        for chat in chats {
            self.chats.put(&mut wtxn, &chat.id, chat)?;
        }
        wtxn.commit()?;
        Ok(())
    }

    pub fn get_chats(&self) -> Result<Vec<Chat>, ChatError> {
        let rtxn = self.env.read_txn()?;
        let mut chats: Vec<Chat> = Vec::new();
        for c in self.chats.iter(&rtxn)? {
            let chat = c?.1;
            chats.push(chat);
        }
        Ok(chats)
    }

    pub fn save_groups(&mut self, groups: &Vec<Group>) -> Result<(), ChatError> {
        if !groups.is_empty() {
            let mut wtxn = self.env.write_txn()?;
            for group in groups {
                self.groups.put(&mut wtxn, &group.id, group)?;
            }
            wtxn.commit()?;
        }
        Ok(())
    }

    pub fn get_groups(&mut self) -> Result<Vec<Group>, ChatError> {
        let rtxn = self.env.read_txn()?;
        let mut groups: Vec<Group> = Vec::new();
        for group in self.groups.iter(&rtxn)? {
            groups.push(group?.1);
        }
        Ok(groups)
    }

    pub fn clear_groups(&mut self) -> Result<(), ChatError> {
        let mut wtxn = self.env.write_txn()?;
        self.groups.clear(&mut wtxn)?;
        wtxn.commit()?;
        Ok(())
    }

    pub fn get_group(&self, group_id: &str) -> Result<Option<Group>, ChatError> {
        let rtxn = self.env.read_txn()?;
        let group = self.groups.get(&rtxn, group_id)?;
        Ok(group)
    }

    pub fn save_messages(&self, messages: &Vec<Message>) -> Result<(), ChatError> {
        let mut wtxn = self.env.write_txn()?;
        for message in messages {
            self.messages.put(&mut wtxn, &message.id, &message)?;
        }
        wtxn.commit()?;
        Ok(())
    }

    pub fn get_messages(&self, ids: &Vec<String>) -> Result<Vec<Message>, ChatError> {
        let rtxn = self.env.read_txn()?;
        let mut messages: Vec<Message> = Vec::new();
        for id in ids {
            match self.messages.get(&rtxn, &id)? {
                Some(message) => messages.push(message),
                None => (),
            }
        }
        Ok(messages)
    }

    pub fn save_poll(&self, poll: &Poll) -> Result<(), ChatError> {
        let mut wtxn = self.env.write_txn()?;
        self.polls.put(&mut wtxn, &poll.id, poll)?;
        wtxn.commit()?;
        Ok(())
    }

    pub fn get_poll(&self, id: &str) -> Result<(), ChatError> {
        let rtxn = self.env.read_txn()?;
        self.polls.get(&rtxn, id)?;
        rtxn.commit()?;
        Ok(())
    }

    pub fn save_event(&self, event: &Event) -> Result<(), ChatError> {
        let mut wtxn = self.env.write_txn()?;
        self.events.put(&mut wtxn, &event.id, event)?;
        wtxn.commit()?;
        Ok(())
    }

    pub fn get_event(&self, id: &str) -> Result<(), ChatError> {
        let rtxn = self.env.read_txn()?;
        self.events.get(&rtxn, id)?;
        rtxn.commit()?;
        Ok(())
    }
}
