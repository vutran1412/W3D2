PRAGMA foreign_keys = ON;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(40) NOT NULL,
  lname VARCHAR(40) NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  author INTEGER,
  FOREIGN KEY(author) REFERENCES users(id)
);

CREATE TABLE question_follows (
  question_id INTEGER,
  user_id INTEGER,
  FOREIGN KEY(question_id) REFERENCES questions(id),
  FOREIGN KEY(user_id) REFERENCES users(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  body TEXT NOT NULL,
  question_id INTEGER,
  user_id INTEGER,
  parent_id INTEGER,
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id)
);

CREATE TABLE question_likes (
  question_id INTEGER,
  user_id INTEGER,
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO  
  users (fname, lname)
VALUES
  ("Preston", "Nowakowski"),
  ("Vu", "Tran");

INSERT INTO
  questions (title, body, author)
VALUES
  ("Shoes", "What are those?", 2),
  ("Location", "Where are we?", 1);

INSERT INTO
  question_follows (question_id, user_id)
VALUES
  ((SELECT id FROM questions WHERE title = "Shoes"), (SELECT id from users WHERE fname = "Preston")),
  ((SELECT id FROM questions WHERE title = "Location"), (SELECT id from users WHERE fname = "Vu"));

  

INSERT INTO
  replies (body, question_id, user_id, parent_id)
VALUES
  ("These are my shoes", 1, 1, NULL),
  ("I don't know what you're talking about", 1, 2, NULL),
  ("I am here", 2, 2, NULL),
  ("No I am here", 2, 1, 3),
  ("OK I guess you are", 2, 2, 4);

INSERT INTO
  question_likes (question_id, user_id)
VALUES
  (1, 1),
  (1, 2),
  (2, 1);

