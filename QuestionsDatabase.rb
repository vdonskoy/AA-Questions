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
end

class Reply
  def self.all
    results =
     QuestionsDatabase.instance.execute('SELECT * FROM replies')
    results.map { |result| Reply.new(result) }
  end

  attr_accessor :id, :body, :questionid, :replyid, :userid

  def initialize(options = {})
    @id, @userid =
     options.values_at('id', 'body', 'questionid', 'replyid', 'userid')
  end

  def create
      raise 'already saved!' unless self.id.nil?

      params = [self.id, self.body, self.questionid, self.replyid self.userid]
      QuestionsDatabase.instance.execute(<<-SQL, *params)
        INSERT INTO
          replies (id, body, questionid, replyid, userid)
        VALUES
          (?, ?, ?, ?, ?)
      SQL

      @id = QuestionsDatabase.instance.last_insert_row_id
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
end