require 'singleton'
require 'sqlite3'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.results_as_hash = true
    self.type_translation = true
  end
end

class User
  def self.all
    results = QuestionsDatabase.instance.execute('SELECT * FROM users')
    results.map { |result| User.new(result) }
  end

  attr_accessor :id, :fname, :lname

  def initialize(options = {})
    @id, @fname, @lname = options.values_at('id', 'fname', 'lname')
  end

  def create
      raise 'already saved!' unless self.id.nil?

      params = [self.fname, self.lname]
      QuestionsDatabase.instance.execute(<<-SQL, *params)
        INSERT INTO
          users (fname,lname)
        VALUES
          (?,?)
      SQL

      @id = QuestionsDatabase.instance.last_insert_row_id
    end

    def self.find_by_name(fname,lname)
      results = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
        SELECT * FROM users
        WHERE users.fname = ? AND users.lname = ?
      SQL
      results.map { |result| User.new(result) }
    end

    def authored_questions
      results = QuestionsDatabase.instance.execute(<<-SQL, self.id)
        SELECT * FROM questions
        WHERE questions.authorid = ?
      SQL
      results.map { |result| Question.new(result) }
    end

    def authored_replies
      results = QuestionsDatabase.instance.execute(<<-SQL, self.id)
        SELECT * FROM replies
        WHERE replies.userid = ?
      SQL
      results.map { |result| Reply.new(result) }
    end

    def followed_questions
      QuestionFollower.followed_questions_for_user_id(self.id)
    end

    def liked_questions
      QuestionLike.liked_questions_for_user_id(self.id)
    end
end

class Question
  def self.all
    results = QuestionsDatabase.instance.execute('SELECT * FROM questions')
    results.map { |result| Question.new(result) }
  end

  attr_accessor :id, :title, :body, :authorid

  def initialize(options = {})
    @id, @title, @body, @authorid =
     options.values_at('id', 'title', 'body', 'authorid')
  end

  def create
    raise 'already saved!' unless self.id.nil?

    params = [self.title, self.body, self.authorid]
    QuestionsDatabase.instance.execute(<<-SQL, *params)
      INSERT INTO
        users (title, body, authorid)
      VALUES
        (?, ?, ?)
      SQL

    @id = QuestionsDatabase.instance.last_insert_row_id
    end

    def self.find_by_author(author_id)
      results = QuestionsDatabase.instance.execute(<<-SQL, author_id)
        SELECT * FROM questions
        WHERE questions.authorid = ?
      SQL
      results.map { |result| Question.new(result)}
    end

    def author
      results = QuestionsDatabase.instance.execute(<<-SQL, self.authorid)
        SELECT * FROM users
        WHERE users.id = ?
      SQL
      results.map { |result| User.new(result)}
    end

    def replies
      results = QuestionsDatabase.instance.execute(<<-SQL, self.id)
        SELECT * FROM replies
        WHERE replies.questionid = ?
      SQL
      results.map { |result| Reply.new(result)}
    end

    def followers
      QuestionFollower.followers_for_question_id(self.id)
    end

    def self.most_followed(n)
      QuestionFollower.most_followed_questions(n)
    end

    def likers
      QuestionLike.likers_for_question_id(self.id)
    end

    def num_likes
      QuestionLike.num_likes_for_question_id(self.id)
    end
end

class QuestionFollower
  def self.all
    results =
     QuestionsDatabase.instance.execute('SELECT * FROM question_followers')
    results.map { |result| QuestionFollower.new(result) }
  end

  attr_accessor :id, :userid

  def initialize(options = {})
    @id, @userid = options.values_at('id', 'userid')
  end

  def create
    raise 'already saved!' unless self.id.nil?

    params = [self.id, self.userid]
    QuestionsDatabase.instance.execute(<<-SQL, *params)
      INSERT INTO
        question_followers (id, userid)
      VALUES
        (?, ?)
      SQL

    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def self.followers_for_question_id(question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT users.* FROM users
      JOIN question_followers ON question_followers.userid = users.id
      WHERE question_followers.questionid = ?
    SQL
    results.map { |result| User.new(result) }
  end

  def self.followed_questions_for_user_id(user_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT questions.* FROM questions
      JOIN question_followers ON question_followers.questionid = questions.id
      WHERE question_followers.userid = ?
    SQL
    results.map { |result| Question.new(result) }
  end

  def self.most_followed_questions(n)
    results = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT COUNT(question_followers.id) FROM question_followers
      JOIN questions ON question_followers.questionid = questions.id
      WHERE question_followers.userid = user.id
      GROUP BY question_followers.questionid
      ORDER BY DESC COUNT(id)
    SQL
    results[0...n].map { |result| Question.new(result) }
  end
end

class Reply
  def self.all
    results =
     QuestionsDatabase.instance.execute('SELECT * FROM replies')
    results.map { |result| Reply.new(result) }
  end

  attr_accessor :id, :body, :questionid, :replyid, :userid

  def initialize(options = {})
    @id, @body, @questionid, @replyid, @userid =
     options.values_at('id', 'body', 'questionid', 'replyid', 'userid')
  end

  def create
      raise 'already saved!' unless self.id.nil?

      params = [self.id, self.body, self.questionid, self.replyid, self.userid]
      QuestionsDatabase.instance.execute(<<-SQL, *params)
        INSERT INTO
          replies (id, body, questionid, replyid, userid)
        VALUES
          (?, ?, ?, ?, ?)
      SQL

      @id = QuestionsDatabase.instance.last_insert_row_id
    end

    def self.find_by_question_id(question_id)
      results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
        SELECT * FROM replies
        WHERE replies.questionid = ?
      SQL
      results.map { |result| p(result); Reply.new(result) }
    end

    def self.find_by_user_id(user_id)
      results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
        SELECT * FROM replies
        WHERE replies.userid = ?
      SQL
      results.map { |result| Reply.new(result) }
    end

    def author
      results = QuestionsDatabase.instance.execute(<<-SQL, self.userid)
        SELECT * FROM users
        WHERE users.id = ?
      SQL
      results.map { |result| User.new(result) }
    end

    def question
      results = QuestionsDatabase.instance.execute(<<-SQL, self.questionid)
        SELECT * FROM questions
        WHERE questions.id = ?
      SQL
      results.map { |result| Question.new(result) }
    end

    def parent_reply
      results = QuestionsDatabase.instance.execute(<<-SQL, self.replyid)
        SELECT * FROM replies
        WHERE replies.id = ?
      SQL
      results.map { |result| Reply.new(result) }
    end

    def child_replies
      results = QuestionsDatabase.instance.execute(<<-SQL, self.id)
        SELECT * FROM replies
        WHERE replies.replyid = ?
      SQL
      results.map { |result| Reply.new(result) }
    end
end

class QuestionLike
  def self.all
    results =
     QuestionsDatabase.instance.execute('SELECT * FROM question_likes')
    results.map { |result| QuestionLike.new(result) }
  end

  attr_accessor :id, :userid, :questionid

  def initialize(options = {})
    @id, @userid, @questionid = options.values_at('id', 'userid', 'questionid')
  end

  def create
    raise 'already saved!' unless self.id.nil?

    params = [self.id, self.userid, self.questionid]
    QuestionsDatabase.instance.execute(<<-SQL, *params)
      INSERT INTO
        question_likes (id, userid, questionid)
      VALUES
        (?, ?)
    SQL

    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def self.likers_for_question_id(question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT users.* FROM users
      JOIN question_likes ON question_likes.userid = users.id
      WHERE question_followers.questionid = ?
    SQL
    results.map { |result| User.new(result) }
  end

  def self.num_likes_for_question_id(question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT COUNT(users.*) FROM users
      JOIN question_likes ON question_likes.userid = users.id
      WHERE question_followers.questionid = ?
    SQL
    results.map { |result| User.new(result) }
  end

  def self.liked_questions_for_user_id(user_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT questions.* FROM questions
      JOIN question_likes ON question_likes.questionid = questions.id
      WHERE question_likes.userid = ?
    SQL
    results.map { |result| Question.new(result) }
  end
end