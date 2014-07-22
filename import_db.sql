CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body VARCHAR(255) NOT NULL,
  authorid INTEGER NOT NULL,
  FOREIGN KEY (authorid) REFERENCES users(id)
);

CREATE TABLE question_followers (
  id INTEGER PRIMARY KEY,
  userid INTEGER NOT NULL,
  FOREIGN KEY (userid) REFERENCES users(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  body VARCHAR(255) NOT NULL,
  questionid INTEGER NOT NULL,
  replyid INTEGER,
  userid INTEGER NOT NULL,
  FOREIGN KEY (questionid) REFERENCES questions(id),
  FOREIGN KEY (replyid) REFERENCES replies(id),
  FOREIGN KEY (userid) REFERENCES users(id)
);

CREATE TABLE question_likes(
  id INTEGER PRIMARY KEY,
  userid INTEGER NOT NULL,
  questionid INTEGER NOT NULL,
  FOREIGN KEY (userid) REFERENCES users(id),
  FOREIGN KEY (questionid) REFERENCES questions(id)
);

INSERT INTO
users(fname,lname)
VALUES
('Vlad','Donskoy'),('Dude','Man'),('Man','Guy');

INSERT INTO
questions(title,body,authorid)
VALUES
('question1','why?',(SELECT id FROM users WHERE fname = 'Vlad')),
('question2','how come?',(SELECT id FROM users WHERE fname = 'Dude'));

INSERT INTO
replies(body, questionid, userid)
VALUES
('because',(SELECT id FROM questions WHERE body = 'why?'),
(SELECT id FROM users WHERE id = '1'));