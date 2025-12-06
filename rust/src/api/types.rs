use flutter_rust_bridge::frb;
use heed::{BytesDecode, BytesEncode};
use regex::Regex;
use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::borrow::Cow;
use std::collections::HashMap;
use std::fmt::Debug;
use std::sync::LazyLock;
use uuid::Uuid;

pub struct ChatError {
    pub message: String,
    pub data: Option<String>,
}

impl ChatError {
    pub fn new(message: &str, data: Option<String>) -> Self {
        return ChatError {
            message: message.to_string(),
            data,
        };
    }
}

impl<T: ToString> From<T> for ChatError {
    fn from(value: T) -> Self {
        return ChatError {
            message: value.to_string(),
            data: None,
        };
    }
}

impl std::fmt::Debug for ChatError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let mut debug = f.debug_struct("ChatError");
        debug.field("message", &self.message);
        if let Some(data) = &self.data {
            match serde_json::from_str::<Value>(&data) {
                Ok(value) => debug.field("data", &format_args!("{:#?}", value)),
                Err(_) => debug.field("data", &self.data),
            };
        } else {
            debug.field("data", &"None");
        }
        debug.finish()
    }
}

// pub trait Id {
//     fn id(&self) -> &String;
// }

#[derive(Debug, Serialize, Deserialize, Default, PartialEq)]
#[frb(ignore)]
pub struct GroupMeMeta(pub String);

#[derive(Debug, Serialize, Deserialize, Default, PartialEq)]
#[serde(default)]
#[frb]
pub struct Me {
    pub id: String,
    #[frb(non_final)]
    pub name: String,
    #[serde(rename(serialize = "avatar_url"), alias = "avatar_url")]
    #[frb(non_final)]
    pub image_url: Option<String>,
    #[frb(non_final)]
    pub phone_number: String,
    #[frb(non_final)]
    pub email: Option<String>,
    #[frb(non_final)]
    pub bio: Option<String>,
    #[frb(non_final)]
    pub song_url: Option<String>,
    #[frb(non_final)]
    pub photo_urls: Vec<String>,
    pub locale: String,
    pub created_at: i64,
    pub updated_at: i64,
    pub share_url: String,
    pub share_qr_code_url: String,
}

#[derive(Debug)]
pub struct MeDeltaState {
    pub change: bool,
    pub name_change: bool,
    pub image_change: bool,
    pub number_change: bool,
    pub email_change: bool,
    pub bio_change: bool,
    pub song_change: bool,
    pub photos_change: bool,

    pub valid: bool,
    pub valid_name: bool,
    pub valid_number: bool,
    pub valid_email: bool,
    pub valid_song: bool,
    pub valid_photos: bool,
}

impl Me {
    #[frb(sync)]
    pub fn compare_delta(&self, delta: &Me) -> MeDeltaState {
        let name_change = self.name != delta.name;
        let image_change = self.image_url != delta.image_url;
        let number_change = self.phone_number != delta.phone_number;
        let email_change = self.email != delta.email;
        let bio_change = self.bio != delta.bio;
        let song_change = self.song_url != delta.song_url;
        let photos_change = self.photo_urls != delta.photo_urls;

        let valid_name = delta.valid_name();
        let valid_number = delta.valid_number();
        let valid_email = delta.valid_email();
        let valid_song = delta.valid_song();
        let valid_photos = delta.valid_photos();

        let state = MeDeltaState {
            change: name_change
                || image_change
                || number_change
                || email_change
                || bio_change
                || song_change
                || photos_change,
            name_change,
            image_change,
            number_change,
            email_change,
            bio_change,
            song_change,
            photos_change,
            valid: valid_name && valid_number && valid_email && valid_song && valid_photos,
            valid_name,
            valid_number,
            valid_email,
            valid_song,
            valid_photos,
        };
        return state;
    }

    #[frb(sync)]
    pub fn equals(&self, other: &Me) -> bool {
        self == other
    }

    #[frb(sync)]
    pub fn initials(&self) -> String {
        let split = self.name.split_once(" ").unwrap_or(("-", "-"));
        return format!(
            "{}{}",
            split.0.chars().nth(0).unwrap(),
            split.1.chars().nth(0).unwrap()
        );
    }

    #[frb(sync)]
    pub fn number(&self) -> (String, String) {
        let split = self.phone_number.split_once(" ").unwrap_or(("+-", "---"));
        return (
            split.0.strip_prefix("+").unwrap().to_string(),
            split.1.to_string(),
        );
    }

    #[frb(sync)]
    pub fn valid(&self) -> bool {
        return self.valid_name()
            && self.valid_email()
            && self.valid_photos()
            && self.valid_number();
    }

    #[frb(sync)]
    pub fn valid_name(&self) -> bool {
        return !self.name.is_empty();
    }

    #[frb(sync)]
    pub fn valid_email(&self) -> bool {
        static EMAIL_RE: LazyLock<Regex> = LazyLock::new(|| {
            Regex::new(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?").unwrap()
        });
        if let Some(email) = &self.email {
            return EMAIL_RE.is_match(email);
        } else {
            return false;
        }
    }

    #[frb(sync)]
    pub fn valid_song(&self) -> bool {
        if let Some(song) = &self.song_url {
            return song.starts_with("https://open.spotify.com/track/");
        } else {
            return true;
        }
    }

    #[frb(sync)]
    pub fn valid_number(&self) -> bool {
        static NUMBER_RE: LazyLock<Regex> =
            LazyLock::new(|| Regex::new(r"^\+\d{1,3} \d{10,12}$").unwrap());
        return NUMBER_RE.is_match(&self.phone_number);
    }

    #[frb(sync)]
    pub fn valid_photos(&self) -> bool {
        let len = self.photo_urls.len();
        return len == 0 || (3 <= len && len <= 6);
    }
}

// impl Id for Me {
//     fn id(&self) -> &String {
//         return &self.id;
//     }
// }

impl TryFrom<&Value> for Me {
    type Error = ChatError;

    fn try_from(value: &Value) -> Result<Self, Self::Error> {
        if value["id"] != Value::Null {
            Ok(Me::deserialize(value)?)
        } else {
            Err(ChatError {
                message: "Cannot convert to Me".to_string(),
                data: Some(value.to_string()),
            })
        }
    }
}

#[derive(Serialize, Deserialize, Debug, Default, Clone)]
#[serde(default)]
#[frb]
pub struct User {
    pub id: String,
    #[frb(non_final)]
    pub name: String,
    #[serde(alias = "avatar_url")]
    #[frb(non_final)]
    pub image_url: String,
    #[frb(non_final)]
    pub bio: Option<String>,
    #[frb(non_final)]
    pub song_url: Option<String>,
    #[frb(non_final)]
    pub photo_urls: Option<Vec<String>>,
    #[frb(non_final)]
    pub shared_groups: Vec<String>,
}

// impl Id for User {
//     fn id(&self) -> &String {
//         return &self.id;
//     }
// }

impl TryFrom<&Value> for User {
    type Error = ChatError;

    fn try_from(value: &Value) -> Result<Self, ChatError> {
        if value["id"] != Value::Null {
            Ok(User::deserialize(value)?)
        } else {
            Err(ChatError {
                message: "Cannot convert to User".to_string(),
                data: Some(value.to_string()),
            })
        }
    }
}

#[derive(Serialize, Deserialize, Debug, Default)]
#[serde(default)]
pub struct Member {
    pub id: String,
    pub user_id: String,
    pub group_id: String,
    pub nickname: String,
    #[serde(default = "member_roles")]
    pub roles: Vec<String>,
    pub muted: bool,
    pub autokicked: bool,
}

fn member_roles() -> Vec<String> {
    return vec!["user".to_string()];
}

// impl Id for Member {
//     fn id(&self) -> &String {
//         return &self.id;
//     }
// }

impl TryFrom<&Value> for Member {
    type Error = ChatError;

    fn try_from(value: &Value) -> Result<Self, Self::Error> {
        if value["id"] != Value::Null {
            Ok(Member::deserialize(value)?)
        } else {
            Err(ChatError {
                message: "Cannot convert to Member".to_string(),
                data: Some(value.to_string()),
            })
        }
    }
}

#[derive(Serialize, Deserialize, Debug, Default)]
#[serde(default)]
pub struct Chat {
    pub id: String,
    pub created_at: i64,
    pub updated_at: i64,
    pub other_user_id: String,
    pub message_ids: Vec<String>,
    pub messages_count: i64,
    pub last_message_id: Option<String>,
}

// impl Id for Chat {
//     fn id(&self) -> &String {
//         return &self.id;
//     }
// }

impl TryFrom<&Value> for Chat {
    type Error = ChatError;

    fn try_from(value: &Value) -> Result<Self, Self::Error> {
        if value["other_user"] != Value::Null {
            let mut chat = Chat::deserialize(value)?;
            chat.id = value["last_message"]["conversation_id"]
                .as_str()
                .unwrap_or_default()
                .to_string();
            chat.other_user_id = value["other_user"]["id"]
                .as_str()
                .unwrap_or_default()
                .to_string();
            chat.last_message_id = value["last_message"]["id"].as_str().map(|s| s.into());
            Ok(chat)
        } else {
            Err(ChatError {
                message: "Cannot convert to Chat".to_string(),
                data: Some(value.to_string()),
            })
        }
    }
}

#[derive(Debug, Serialize, Deserialize, Default, PartialEq)]
#[serde(default)]
pub struct Group {
    pub id: String,
    pub name: String,
    #[serde(alias = "type")]
    pub group_type: String,
    pub description: Option<String>,
    pub image_url: Option<String>,
    pub creator_user_id: String,
    pub created_at: i64,
    pub updated_at: i64,
    pub message_ids: Vec<String>,
    pub messages_count: i64,
    pub last_message_id: Option<String>,
    pub last_message_created_at: i64,
    pub last_message_updated_at: i64,
    pub theme_name: Option<String>,
    pub requires_approval: bool,
    pub show_join_question: bool,
    pub the_join_question: Option<String>,
    pub message_deletion_mode: Vec<String>,
    pub share_url: Option<String>,
    pub share_qr_code_url: Option<String>,
    pub members_saved: bool,
    pub messages_saved: bool,
}

// impl Id for Group {
//     fn id(&self) -> &String {
//         return &self.id;
//     }
// }

impl TryFrom<&Value> for Group {
    type Error = ChatError;

    fn try_from(value: &Value) -> Result<Self, ChatError> {
        if value["id"] != Value::Null {
            let mut group = Group::deserialize(value)?;
            group.messages_count = value["messages"]["count"].as_i64().unwrap_or(0);
            group.last_message_id = value["messages"]["last_message_id"]
                .as_str()
                .map(|s| s.to_string());
            group.last_message_created_at = value["messages"]["last_message_created_at"]
                .as_i64()
                .unwrap_or(0);
            group.last_message_updated_at = value["messages"]["last_message_updated_at"]
                .as_i64()
                .unwrap_or(0);
            group.the_join_question = value["join_question"]["text"]
                .as_str()
                .map(|s| s.to_string());
            Ok(group)
        } else {
            Err(ChatError {
                message: "Cannot convert to Group".to_string(),
                data: Some(value.to_string()),
            })
        }
    }
}

#[derive(Serialize, Deserialize, Debug, Default)]
#[serde(default)]
#[frb]
pub struct Message {
    pub id: String,
    pub group_id: String,
    pub sender_id: String,
    pub system: bool,
    #[frb(non_final)]
    pub text: Option<String>,
    #[frb(non_final)]
    pub reactions: Vec<Reaction>,
    #[frb(non_final)]
    pub attachments: Vec<Attachment>,
    pub source_guid: String,
    #[frb(non_final)]
    pub pinned_at: Option<i64>,
    pub created_at: i64,
    pub updated_at: Option<i64>,
    #[frb(non_final)]
    pub sending: bool,
}

impl Message {
    pub fn new(group_id: &str, text: &str, attachments: Option<Vec<Attachment>>) -> Self {
        return Message {
            group_id: group_id.to_string(),
            text: Some(text.to_string()),
            attachments: attachments.unwrap_or_default(),
            source_guid: Uuid::new_v4().to_string(),
            ..Default::default()
        };
    }
}

// impl Id for Message {
//     fn id(&self) -> &String {
//         return &self.id;
//     }
// }

impl TryFrom<&Value> for Message {
    type Error = ChatError;

    fn try_from(value: &Value) -> Result<Self, Self::Error> {
        if value["id"] != Value::Null {
            Ok(Message::deserialize(value)?)
        } else {
            Err(ChatError {
                message: "Cannot convert to Message".to_string(),
                data: Some(value.to_string()),
            })
        }
    }
}

#[derive(Serialize, Deserialize, Debug, Default)]
#[serde(default)]
pub struct Reaction {
    #[serde(alias = "code", default = "empty_unicode")]
    pub unicode: String,
    pub user_ids: Vec<String>,
}

pub fn empty_unicode() -> String {
    return "�".to_string();
}

#[derive(Serialize, Deserialize, Debug)]
#[serde(tag = "type")]
pub enum Attachment {
    #[serde(alias = "image")]
    Image {
        url: String,
    },
    #[serde(alias = "mentions")]
    Mentions {
        loci: Vec<Vec<i32>>,
        user_ids: Vec<String>,
    },
    #[serde(alias = "reply")]
    Reply {
        #[serde(alias = "reply_id")]
        message_id: String,
    },
    #[serde(alias = "poll")]
    Poll {
        poll_id: String,
    },
    #[serde(alias = "file")]
    File {
        file_id: String,
    },
    #[serde(alias = "location")]
    Location {
        name: String,
        lat: String,
        lng: String,
    },
    #[serde(alias = "event")]
    Event {
        event_id: String,
    },
    Unsupported(Value),
}

#[derive(Serialize, Deserialize, Debug, Default)]
#[serde(default)]
pub struct Poll {
    pub id: String,
    pub subject: String,
    pub owner_id: String,
    #[serde(alias = "conversation_id")]
    pub group_id: String,
    pub created_at: i64,
    #[serde(alias = "last_modified")]
    pub updated_at: i64,
    pub expiration: i64,
    pub status: String,
    pub options: Vec<PollOption>,
    #[serde(rename = "type")]
    pub voting_type: VotingType,
    pub visibility: Visibility,
    pub user_votes: Vec<String>,
}

impl Poll {
    pub fn new(
        subject: &str,
        voting_type: VotingType,
        visibility: Visibility,
        options: Vec<PollOption>,
        expiration: i64,
    ) -> Poll {
        return Poll {
            subject: subject.to_string(),
            voting_type,
            visibility,
            options,
            expiration,
            ..Poll::default()
        };
    }
}

// impl Id for Poll {
//     fn id(&self) -> &String {
//         return &self.id;
//     }
// }

impl TryFrom<&Value> for Poll {
    type Error = ChatError;

    fn try_from(value: &Value) -> Result<Self, Self::Error> {
        if value["data"]["id"] != Value::Null {
            let mut poll = Poll::deserialize(&value["data"])?;
            if let Value::Array(user_votes) = &value["user_votes"] {
                for vote in user_votes {
                    if let Value::String(s) = vote {
                        poll.user_votes.push(s.to_string());
                    }
                }
            }
            Ok(poll)
        } else {
            Err(ChatError {
                message: "Cannot convert to Poll".to_string(),
                data: Some(value.to_string()),
            })
        }
    }
}

#[derive(Serialize, Deserialize, Debug, Default, PartialEq)]
pub enum VotingType {
    #[serde(rename = "single")]
    #[default]
    Single,
    #[serde(rename = "multi")]
    Multiple,
}

#[derive(Serialize, Deserialize, Debug, Default)]
pub enum Visibility {
    #[serde(rename = "anonymous")]
    #[default]
    Anonymous,
    #[serde(rename = "public")]
    Public,
}

#[derive(Serialize, Deserialize, Debug, Default)]
#[serde(default)]
pub struct PollOption {
    pub id: String,
    pub title: String,
    pub votes: i32,
    pub voter_ids: Option<Vec<String>>,
}

impl PollOption {
    pub fn new(id: i32, title: &str) -> PollOption {
        return PollOption {
            id: id.to_string(),
            title: title.to_string(),
            votes: 0,
            voter_ids: None,
        };
    }
}

#[derive(Serialize, Deserialize, Debug, Default)]
#[serde(default)]
pub struct Event {
    #[serde(alias = "event_id")]
    pub id: String,
    #[serde(alias = "conversation_id")]
    pub group_id: String,
    pub creator_id: String,
    pub name: String,
    pub description: String,
    pub location: Option<EventLocation>,
    pub start_at: String,
    pub end_at: String,
    pub is_all_day: bool,
    pub timezone: String,
    pub reminders: Vec<i32>,
    pub going: Vec<String>,
    pub not_going: Vec<String>,
    pub created_at: String,
    pub updated_at: String,
    pub share_url: String,
    pub share_qr_code: String,
}

impl Event {
    pub fn new(
        name: &str,
        description: &str,
        start_at: &str,
        end_at: &str,
        timezone: &str,
        is_all_day: bool,
        location: Option<EventLocation>,
        reminders: Vec<i32>,
    ) -> Event {
        return Event {
            name: name.to_string(),
            description: description.to_string(),
            start_at: start_at.to_string(),
            end_at: end_at.to_string(),
            timezone: timezone.to_string(),
            is_all_day,
            location,
            reminders,
            ..Event::default()
        };
    }
}

// impl Id for Event {
//     fn id(&self) -> &String {
//         return &self.id;
//     }
// }

#[derive(Serialize, Deserialize, Debug, Default)]
#[serde(default)]
pub struct EventLocation {
    pub name: String,
    pub address: String,
    pub lat: f64,
    pub lng: f64,
}

#[frb(ignore)]
pub struct DbItem<T>(T);

#[frb(ignore)]
impl<'a, T: Serialize + 'a> BytesEncode<'a> for DbItem<T> {
    type EItem = T;

    fn bytes_encode(item: &'a Self::EItem) -> Result<Cow<'a, [u8]>, heed::BoxedError> {
        let buffer = rmp_serde::to_vec(item)?;
        Ok(Cow::Owned(buffer))
    }
}

#[frb(ignore)]
impl<'a, T: Deserialize<'a> + 'a> BytesDecode<'a> for DbItem<T> {
    type DItem = T;

    fn bytes_decode(bytes: &'a [u8]) -> Result<Self::DItem, heed::BoxedError> {
        let item: T = rmp_serde::from_slice(bytes)?;
        Ok(item)
    }
}
