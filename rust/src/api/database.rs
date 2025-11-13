use crate::api::types::*;
use flutter_rust_bridge::frb;
use heed::{types::*, Database, Env, EnvOpenOptions};
use std::fs;

#[frb(ignore)]
pub struct Db {
    #[frb(ignore)]
    pub env: Env,
    #[frb(ignore)]
    me: Database<Str, DbItem<Me>>,
    users: Database<Str, DbItem<User>>,
    members: Database<Str, DbItem<Member>>,
    chats: Database<Str, DbItem<Chat>>,
    groups: Database<Str, DbItem<Group>>,
    messages: Database<Str, DbItem<Message>>,
    polls: Database<Str, DbItem<Poll>>,
    events: Database<Str, DbItem<Event>>,
    folder: String,
}

#[frb(ignore)]
impl Db {
    pub fn open(folder: String) -> Result<Db, ChatError> {
        let path = format!("{folder}/GroupChatDb");
        if !fs::exists(&path)? {
            fs::create_dir(&path)?;
        }
        let env = unsafe { EnvOpenOptions::new().max_dbs(20).open(path)? };
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
            env,
            me,
            users,
            members,
            chats,
            groups,
            messages,
            polls,
            events,
            folder,
        })
    }

    pub fn compact(self) -> Result<Db, ChatError> {
        let compact_path = format!("{}/GroupChatDbCompacted", self.folder);
        let path = format!("{}/GroupChatDb", self.folder);
        self.env
            .copy_to_path(&compact_path, heed::CompactionOption::Enabled)?;
        self.env.prepare_for_closing().wait();
        fs::rename(&compact_path, path)?;
        Ok(Db::open(self.folder)?)
    }

    pub fn save_me(&self, me: &Me) -> Result<(), ChatError> {
        let mut wtxn = self.env.write_txn()?;
        self.me.put(&mut wtxn, &me.id, &me)?;
        wtxn.commit()?;
        Ok(())
    }

    pub fn get_me(&self) -> Result<Option<Me>, ChatError> {
        let rtxn = self.env.read_txn()?;
        let me: Option<Me>;
        match self.me.first(&rtxn)? {
            Some(m) => me = Some(m.1),
            None => me = None,
        }
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

    pub fn save_groups(&self, groups: &Vec<Group>) -> Result<(), ChatError> {
        let mut wtxn = self.env.write_txn()?;
        for group in groups {
            self.groups.put(&mut wtxn, &group.id, group)?;
        }
        wtxn.commit()?;
        Ok(())
    }

    pub fn get_groups(&self) -> Result<Vec<Group>, ChatError> {
        let rtxn = self.env.read_txn()?;
        let mut groups: Vec<Group> = Vec::new();
        for g in self.groups.iter(&rtxn)? {
            let group = g?.1;
            groups.push(group);
        }
        Ok(groups)
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
