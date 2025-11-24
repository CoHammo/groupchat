use crate::api::types::*;
use flutter_rust_bridge::frb;
use jiff::Timestamp;
use reqwest::{
    header::{HeaderMap, HeaderValue},
    Client,
};
use serde::Deserialize;
use serde_json::{json, Value};
use std::collections::HashMap;

#[derive(Debug)]
#[frb(ignore)]
pub struct Api {
    #[frb(ignore)]
    pub api: Client,

    #[frb(ignore)]
    url: &'static str,
}

#[frb(ignore)]
impl Api {
    pub fn new(token: &str) -> Result<Api, ChatError> {
        let mut headers = HeaderMap::new();
        headers.insert("X-Access-Token", HeaderValue::from_str(token)?);
        let cb = Client::builder().default_headers(headers);

        Ok(Api {
            api: cb.build()?,
            url: "https://api.groupme.com/v3",
        })
    }

    pub async fn get_me(&self) -> Result<Me, ChatError> {
        let res = self
            .api
            .get(format!("{}/users/me", self.url))
            .send()
            .await?;

        if res.status() == 200 {
            let json = &res.json::<Value>().await?["response"];
            let me = Me::try_from(json)?;
            Ok(me)
        } else {
            Err(ChatError::new(
                &format!("API get_me: {}", res.status()),
                res.text().await?,
            ))
        }
    }

    pub async fn update_me(&self, me: &Me) -> Result<Me, ChatError> {
        let res = self
            .api
            .post(format!("https://v2.groupme.com/users/{}", me.id))
            .json(&json!({"user": &me}))
            .send()
            .await?;

        if res.status() == 200 {
            let json = &res.json::<Value>().await?["response"]["user"];
            let new_me = Me {
                share_url: me.share_url.clone(),
                share_qr_code_url: me.share_qr_code_url.clone(),
                ..Me::try_from(json)?
            };
            Ok(new_me)
        } else {
            Err(ChatError::new(
                &format!("API update_me: {}", res.status()),
                res.text().await?,
            ))
        }
    }

    pub async fn get_user(&self, user_id: &str) -> Result<User, ChatError> {
        let res = self
            .api
            .get(format!("https://v2.groupme.com/users/{user_id}"))
            .send()
            .await?;

        if res.status() == 200 {
            let json = &res.json::<Value>().await?["response"]["user"];
            Ok(User::deserialize(json)?)
        } else {
            Err(ChatError::new(
                &format!("API get_user: {}", res.status()),
                res.text().await?,
            ))
        }
    }

    pub async fn get_chats(&self, page: i64, page_size: i64) -> Result<Vec<Chat>, ChatError> {
        let res = self
            .api
            .get(format!("{}/chats", self.url))
            .query(&[("page", page), ("per_page", page_size)])
            .send()
            .await?;

        if res.status() == 200 {
            let json = &res.json::<Value>().await?["response"];
            let mut chats: Vec<Chat> = Vec::new();
            if let Value::Array(values) = json {
                for value in values {
                    chats.push(Chat::try_from(value)?);
                }
                Ok(chats)
            } else {
                Err(ChatError::new(
                    "API get_chats returned bad data",
                    json.to_string(),
                ))
            }
        } else {
            Err(ChatError::new(
                &format!("API get_chats: {}", res.status()),
                res.text().await?,
            ))
        }
    }

    pub async fn create_group(
        &self,
        name: &str,
        description: Option<String>,
        share: bool,
        group_type: &str,
    ) -> Result<Group, ChatError> {
        let res = self
            .api
            .post(format!("{}/groups", self.url))
            .json(&json!({
                "name": name, "description": description, "share": share, "type": group_type
            }))
            .send()
            .await?;

        if res.status() == 201 {
            let json = &res.json::<Value>().await?["response"];
            Ok(Group::try_from(json)?)
        } else {
            Err(ChatError::new(
                &format!("API create_group: {}", res.status()),
                res.text().await?,
            ))
        }
    }

    pub async fn delete_group(&self, group_id: &str) -> Result<(), ChatError> {
        let res = self
            .api
            .post(format!("{}/groups/{group_id}/destroy", self.url))
            .send()
            .await?;

        if res.status() == 200 {
            Ok(())
        } else {
            Err(ChatError::new(
                &format!("API delete_group: {}", res.status()),
                res.text().await?,
            ))
        }
    }

    pub async fn join_group(&self, group_id: &str, share_token: &str) -> Result<Group, ChatError> {
        let res = self
            .api
            .get(format!("{}/groups/{group_id}/join/{share_token}", self.url))
            .send()
            .await?;

        if res.status() == 200 {
            let json = &res.json::<Value>().await?["group"];
            Ok(Group::try_from(json)?)
        } else {
            Err(ChatError::new(
                &format!("API join_group: {}", res.status()),
                res.text().await?,
            ))
        }
    }

    pub async fn rejoin_group(&self, group_id: &str) -> Result<Group, ChatError> {
        let res = self
            .api
            .get(format!("{}/groups/{group_id}/join", self.url))
            .send()
            .await?;

        if res.status() == 200 {
            let json = &res.json::<Value>().await?;
            Ok(Group::try_from(json)?)
        } else {
            Err(ChatError::new(
                &format!("API rejoin_group: {}", res.status()),
                res.text().await?,
            ))
        }
    }

    pub async fn get_group(&self, group_id: &str) -> Result<Group, ChatError> {
        let res = self
            .api
            .get(format!("{}/groups/{group_id}", self.url))
            .send()
            .await?;

        if res.status() == 200 {
            let json = &res.json::<Value>().await?["response"];
            Ok(Group::try_from(json)?)
        } else {
            Err(ChatError::new(
                &format!("API get_group: {}", res.status()),
                res.text().await?,
            ))
        }
    }

    pub async fn get_groups(&self, page: i64, page_size: i64) -> Result<Vec<Group>, ChatError> {
        let res = self
            .api
            .get(format!("{}/groups", self.url))
            .query(&[("page", page), ("per_page", page_size)])
            .send()
            .await?;

        if res.status() == 200 {
            let json = &res.json::<Value>().await?["response"];
            let mut groups: Vec<Group> = Vec::new();
            if let Value::Array(values) = json {
                for value in values {
                    groups.push(Group::try_from(value)?);
                }
                Ok(groups)
            } else {
                Err(ChatError::new(
                    "API get_groups returned bad data",
                    json.to_string(),
                ))
            }
        } else {
            Err(ChatError::new(
                &format!("API get_groups: {}", res.status()),
                res.text().await?,
            ))
        }
    }

    pub async fn get_members(&self, group_id: &str) -> Result<Vec<Member>, ChatError> {
        let res = self
            .api
            .get(format!("{}/groups/{group_id}", self.url))
            .send()
            .await?;

        if res.status() == 200 {
            let json = &res.json::<Value>().await?["response"]["members"];
            let mut members: Vec<Member> = Vec::new();
            if let Value::Array(values) = json {
                for value in values {
                    members.push(Member::try_from(value)?);
                }
                Ok(members)
            } else {
                Err(ChatError::new(
                    "API get_members returned bad data",
                    json.to_string(),
                ))
            }
        } else {
            Err(ChatError::new(
                &format!("API get_members: {}", res.status()),
                res.text().await?,
            ))
        }
    }

    pub async fn add_members(
        &self,
        group_id: &str,
        users: Vec<User>,
    ) -> Result<Vec<Member>, ChatError> {
        let mut members: Vec<HashMap<&str, String>> = vec![];
        for user in users {
            members.push(HashMap::from([
                ("user_id", user.id),
                ("nickname", user.name),
            ]));
        }

        let res = self
            .api
            .post(format!("{}/groups/{group_id}/members/add", self.url))
            .json(&json!({"members": members}))
            .send()
            .await?;

        if res.status() == 202 {
            let json = &res.json::<Value>().await?["response"]["results_id"];
            let mut call: String = "".to_string();
            if let Value::String(results_id) = json {
                call = format!(
                    "{}/groups/{group_id}/members/results/{results_id}",
                    self.url
                )
            }
            let mut res2 = self.api.get(&call).send().await?;
            while res2.status() != 200 {
                if res2.status() == 503 {
                    res2 = self.api.get(&call).send().await?;
                } else {
                    return Err(ChatError::new(
                        &format!("API add_members results call: {}", res2.status()),
                        res2.text().await?,
                    ));
                }
            }

            let members_json = &res2.json::<Value>().await?["response"]["members"];
            let mut new_members: Vec<Member> = Vec::new();
            if let Value::Array(values) = members_json {
                for value in values {
                    new_members.push(Member::try_from(value)?);
                }
            }

            Ok(new_members)
        } else {
            Err(ChatError::new(
                &format!("API add_members: {}", res.status()),
                res.text().await?,
            ))
        }
    }

    pub async fn remove_member(&self, group_id: &str, member_id: &str) -> Result<bool, ChatError> {
        let res = self
            .api
            .post(format!(
                "{}/groups/{group_id}/members/{member_id}/remove",
                self.url,
            ))
            .send()
            .await?;

        if res.status() == 200 {
            Ok(true)
        } else {
            Err(ChatError::new(
                &format!("API remove_member: {}", res.status()),
                res.text().await?,
            ))
        }
    }

    pub async fn get_messages(
        &self,
        group_id: &str,
        limit: i64,
        before_id: Option<String>,
        after_id: Option<String>,
        since_id: Option<String>,
    ) -> Result<Vec<Message>, ChatError> {
        let res = self
            .api
            .get(format!("{}/groups/{group_id}/messages", self.url))
            .query(&[
                ("limit", &limit.to_string()),
                ("before_id", &before_id.unwrap_or_default()),
                ("after_id", &after_id.unwrap_or_default()),
                ("since_id", &since_id.unwrap_or_default()),
            ])
            .send()
            .await?;

        if res.status() == 200 {
            let json = &mut res.json::<Value>().await?["response"]["messages"];
            let mut messages: Vec<Message> = Vec::new();
            if let Value::Array(values) = json {
                for value in values {
                    let mut attachments: Vec<Attachment> = Vec::new();
                    if let Value::Array(attachment_values) = &value["attachments"] {
                        for attachment_value in attachment_values {
                            match Attachment::deserialize(attachment_value) {
                                Ok(attachment) => attachments.push(attachment),
                                Err(_) => attachments
                                    .push(Attachment::Unsupported(attachment_value.clone())),
                            }
                        }
                    }
                    value["attachments"] = Value::Array(Vec::new());
                    let mut message = Message::try_from(&*value)?;
                    message.group_id = group_id.to_string();
                    message.attachments = attachments;
                    messages.push(message);
                }
                return Ok(messages);
            } else {
                return Err(ChatError::new(
                    "API get_message returned bad data",
                    json.to_string(),
                ));
            }
        } else {
            Err(ChatError::new(
                &format!("API get_messages: {}", res.status()),
                res.text().await?,
            ))
        }
    }

    pub async fn send_message(&self, message: &Message) -> Result<Message, ChatError> {
        let res = self
            .api
            .post(format!("{}/groups/{}/messages", self.url, message.group_id))
            .json(&json!({
                "message": {
                    "source_guid": message.source_guid,
                    "text": message.text,
                    "attachments": message.attachments
                }
            }))
            .send()
            .await?;

        if res.status() == 201 {
            let json = &res.json::<Value>().await?["response"]["message"];
            Ok(Message::try_from(json)?)
        } else {
            Err(ChatError::new(
                &format!("API send_message: {}", res.status()),
                res.text().await?,
            ))
        }
    }

    pub async fn edit_message(
        &self,
        group_id: &str,
        message_id: &str,
        text: &str,
    ) -> Result<Message, ChatError> {
        let res = self
            .api
            .put(format!(
                "https://api.groupme.com/v4/groups/{group_id}/messages/{message_id}",
            ))
            .json(&json!({"text": text}))
            .send()
            .await?;

        if res.status() == 200 {
            let json = &res.json::<Value>().await?["response"]["message"];
            Ok(Message::try_from(json)?)
        } else {
            Err(ChatError::new(
                &format!("API edit_message: {}", res.status()),
                res.text().await?,
            ))
        }
    }

    pub async fn delete_message(
        &self,
        group_id: &str,
        message_id: &str,
    ) -> Result<bool, ChatError> {
        let res = self
            .api
            .delete(format!(
                "{}/conversations/{group_id}/messages/{message_id}",
                self.url
            ))
            .send()
            .await?;

        if res.status() == 204 {
            Ok(true)
        } else {
            Err(ChatError::new(
                &format!("API delete_message: {}", res.status()),
                res.text().await?,
            ))
        }
    }

    pub async fn like_message(
        &self,
        group_id: &str,
        message_id: &str,
        unicode: &str,
    ) -> Result<Vec<Reaction>, ChatError> {
        let res = self
            .api
            .post(format!(
                "{}/messages/{group_id}/{message_id}/like",
                self.url
            ))
            .json(&json!({"like_icon": {"type": "unicode", "code": unicode} }))
            .send()
            .await?;

        if res.status() == 200 {
            let json = &res.json::<Value>().await?["response"]["reactions"];
            let mut reactions: Vec<Reaction> = Vec::new();
            if let Value::Array(values) = json {
                for value in values {
                    reactions.push(Reaction::deserialize(value)?);
                }
                Ok(reactions)
            } else {
                Err(ChatError::new(
                    "API like_message returned bad data",
                    json.to_string(),
                ))
            }
        } else {
            Err(ChatError::new(
                &format!("API like_message: {}", res.status()),
                res.text().await?,
            ))
        }
    }

    pub async fn unlike_message(
        &self,
        group_id: &str,
        message_id: &str,
    ) -> Result<Vec<Reaction>, ChatError> {
        let res = self
            .api
            .post(format!(
                "{}/messages/{group_id}/{message_id}/unlike",
                self.url
            ))
            .send()
            .await?;

        if res.status() == 200 {
            let json = &res.json::<Value>().await?["response"]["reactions"];
            let mut reactions: Vec<Reaction> = Vec::new();
            if let Value::Array(reacts) = json {
                for react in reacts {
                    reactions.push(Reaction::deserialize(react)?);
                }
                Ok(reactions)
            } else {
                Err(ChatError::new(
                    "API unlike_message returned bad data",
                    json.to_string(),
                ))
            }
        } else {
            Err(ChatError::new(
                &format!("API unlike_message: {}", res.status()),
                res.text().await?,
            ))
        }
    }

    pub async fn pin_message(&self, group_id: &str, message_id: &str) -> Result<bool, ChatError> {
        let res = self
            .api
            .post(format!(
                "{}/conversations/{group_id}/messages/{message_id}/pin",
                self.url
            ))
            .send()
            .await?;

        if res.status() == 200 {
            Ok(true)
        } else {
            Err(ChatError::new(
                &format!("API pin_message: {}", res.status()),
                res.text().await?,
            ))
        }
    }

    pub async fn unpin_message(&self, group_id: &str, message_id: &str) -> Result<bool, ChatError> {
        let res = self
            .api
            .post(format!(
                "{}/conversations/{group_id}/messages/{message_id}/unpin",
                self.url
            ))
            .send()
            .await?;

        if res.status() == 200 {
            Ok(true)
        } else {
            Err(ChatError::new(
                &format!("API pin_message: {}", res.status()),
                res.text().await?,
            ))
        }
    }

    pub async fn upload_image(&self, image: Vec<u8>) -> Result<Attachment, ChatError> {
        let res = self
            .api
            .post("https://image.groupme.com/pictures")
            .body(image)
            .send()
            .await?;

        if res.status() == 200 {
            let json = &res.json::<Value>().await?["payload"]["url"];
            if let Value::String(url) = json {
                Ok(Attachment::Image {
                    url: url.to_string(),
                })
            } else {
                Err(ChatError::new(
                    "API upload_image returned bad data",
                    json.to_string(),
                ))
            }
        } else {
            Err(ChatError::new(
                &format!("API upload_image: {}", res.status()),
                res.text().await?,
            ))
        }
    }

    pub async fn create_poll(
        &self,
        group_id: &str,
        poll: &Poll,
    ) -> Result<(Poll, Message), ChatError> {
        let res = self
            .api
            .post(format!("{}/poll/{group_id}", self.url))
            .json(&poll)
            .send()
            .await?;

        if res.status() == 201 {
            let json = &res.json::<Value>().await?["response"];
            let full_poll = Poll::deserialize(&json["poll"]["data"])?;
            let message = Message::try_from(&json["message"])?;
            Ok((full_poll, message))
        } else {
            Err(ChatError::new(
                &format!("API create_poll: {}", res.status()),
                res.text().await?,
            ))
        }
    }

    pub async fn get_poll(&self, group_id: &str, poll_id: &str) -> Result<Poll, ChatError> {
        let res = self
            .api
            .get(format!("{}/poll/{group_id}/{poll_id}", self.url))
            .send()
            .await?;

        if res.status() == 200 {
            let json = &res.json::<Value>().await?["response"]["poll"];
            Ok(Poll::try_from(json)?)
        } else {
            Err(ChatError::new(
                &format!("API get_poll: {}", res.status()),
                res.text().await?,
            ))
        }
    }

    pub async fn get_polls(&self, group_id: &str) -> Result<Vec<Poll>, ChatError> {
        let res = self
            .api
            .get(format!("{}/poll/{group_id}", self.url))
            .send()
            .await?;

        if res.status() == 200 {
            let json = &res.json::<Value>().await?["response"]["polls"];
            let mut polls: Vec<Poll> = Vec::new();
            if let Value::Array(values) = json {
                for value in values {
                    polls.push(Poll::try_from(value)?);
                }
                Ok(polls)
            } else {
                Err(ChatError::new(
                    "API get_polls returned bad data",
                    json.to_string(),
                ))
            }
        } else {
            Err(ChatError::new(
                &format!("API get_polls: {}", res.status()),
                res.text().await?,
            ))
        }
    }

    pub async fn vote_poll(
        &self,
        group_id: &str,
        poll_id: &str,
        voting_type: VotingType,
        votes: Vec<String>,
    ) -> Result<Poll, ChatError> {
        let url: String;
        let mut v: Option<Vec<String>> = None;
        if voting_type == VotingType::Single {
            url = format!("{}/poll/{group_id}/{poll_id}/{}", self.url, votes[0]);
        } else {
            url = format!("{}/poll/{group_id}/{poll_id}", self.url,);
            v = Some(votes);
        }
        let res = self.api.post(url).json(&json!({"votes": v})).send().await?;

        if res.status() == 200 {
            let json = &res.json::<Value>().await?["response"]["poll"];
            Ok(Poll::try_from(json)?)
        } else {
            Err(ChatError::new(
                &format!("API vote_poll: {}", res.status()),
                res.text().await?,
            ))
        }
    }

    pub async fn upload_file(
        &self,
        group_id: &str,
        filename: &str,
        file: Vec<u8>,
    ) -> Result<Attachment, ChatError> {
        let res = self
            .api
            .post(format!(
                "https://file.groupme.com/v1/{group_id}/files?name={filename}"
            ))
            .body(file)
            .send()
            .await?;

        if res.status() == 201 {
            let json = res.json::<Value>().await?;
            if let Value::String(url) = &json["status_url"] {
                if let Some(file_id) = url.split_once("=") {
                    return Ok(Attachment::File {
                        file_id: file_id.1.to_string(),
                    });
                }
            }
            Err(ChatError::new(
                &format!("API upload_file returned bad data"),
                json.to_string(),
            ))
        } else {
            Err(ChatError::new(
                &format!("API upload_file: {}", res.status()),
                res.text().await?,
            ))
        }
    }

    pub async fn create_event(
        &self,
        group_id: &str,
        event: &Event,
    ) -> Result<(Event, Message), ChatError> {
        let res = self
            .api
            .post(format!(
                "{}/conversations/{group_id}/events/create",
                self.url
            ))
            .json(&event)
            .send()
            .await?;

        if res.status() == 201 {
            let json = &res.json::<Value>().await?["response"];
            let event = Event::deserialize(&json["event"])?;
            let message = Message::try_from(&json["message"])?;
            Ok((event, message))
        } else {
            Err(ChatError::new(
                &format!("API create_event: {}", res.status()),
                res.text().await?,
            ))
        }
    }

    pub async fn get_event(&self, group_id: &str, event_id: &str) -> Result<Event, ChatError> {
        let res = self
            .api
            .get(format!("{}/conversations/{group_id}/events/show", self.url))
            .query(&[("event_id", event_id)])
            .send()
            .await?;

        if res.status() == 200 {
            let json = &res.json::<Value>().await?["response"]["event"];
            Ok(Event::deserialize(json)?)
        } else {
            Err(ChatError::new(
                &format!("API get_event: {}", res.status()),
                res.text().await?,
            ))
        }
    }

    pub async fn get_events(&self, group_id: &str) -> Result<Vec<Event>, ChatError> {
        let res = self
            .api
            .get(format!("{}/conversations/{group_id}/events/list", self.url))
            .query(&[("end_at", Timestamp::now().to_string())])
            .send()
            .await?;

        if res.status() == 200 {
            let json = &res.json::<Value>().await?["response"]["events"];
            let mut events: Vec<Event> = Vec::new();
            if let Value::Array(values) = json {
                for value in values {
                    events.push(Event::deserialize(value)?);
                }
                Ok(events)
            } else {
                Err(ChatError::new(
                    &format!("API get_events returned bad data"),
                    json.to_string(),
                ))
            }
        } else {
            Err(ChatError::new(
                &format!("API get_events: {}", res.status()),
                res.text().await?,
            ))
        }
    }
}
