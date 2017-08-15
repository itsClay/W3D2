DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(70) NOT NULL,
  lname VARCHAR(70) NOT NULL
);

DROP TABLE if exists questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  parent_reply_id INTEGER,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_reply_id) REFERENCES replies(id)
);

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  users(fname, lname)
VALUES
  ('Ron','Swanson'),
  ('Jon','Snow'),
  ('Slash', ' '),
  ('Dennis','Rodman');

INSERT INTO
  questions(title, body, author_id)
VALUES
  ('Blue?','Why is the sky blue?',1),
  ('Snow','Is my last name a color or precipitation?',2),
  ('...','...........',3),
  ('Kim?','What''s for dinner?',4);

INSERT INTO
  replies(question_id, parent_reply_id, body, user_id)
VALUES
  (1, NULL, 'Rods and Cones', 3),
  (1, 1, 'Wrong its the gods!!', 2),
  (2, NULL, 'It''s cold ran', 4);

INSERT INTO
  question_likes(user_id, question_id)
VALUES
  (1, 3),
  (1, 4),
  (2,1);

INSERT INTO
  question_follows (user_id, question_id)
VALUES
  (1, 3),
  (1, 2),
  (3, 2),
  (4, 3);
