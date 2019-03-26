require 'singleton'
require 'sqlite3'

class QuestionsDatabase < SQLite3::Database 
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end 

end

class User 
  def self.all
    data = QuestionsDatabase.instance.execute(
      "SELECT * FROM users"
    )
    data.map { |datum| User.new(datum) }
  end

  def self.find_by_name(fname, lname)
    QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT * FROM users WHERE fname = ? AND lname = ?
    SQL
  end

  def initialize(user_data = User.all)
    @id = user_data['id'] 
    @fname = user_data['fname']
    @lname = user_data['lname']
  end

  def authored_questions
    Question.find_by_author_id(id)
  end

  def authored_replies
    Reply.find_by_user_id(id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(id)
  end

  private
  attr_reader :id, :fname, :lname
end

class Question
  def self.all
    data = QuestionsDatabase.instance.execute(
      "SELECT * FROM questions"
    )
    data.map { |datum| Question.new(datum) }
  end

  def self.find_by_author_id(author_id)
    QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT * FROM questions WHERE author = ?
    SQL
  end
    
  def initialize(question_data)
    @id = question_data["id"]
    @title = question_data["title"]
    @body = question_data["body"]
    @author = question_data["author"]
  end

  def author
    @author
  end

  def replies
    Reply.find_by_question_id(id)
  end

  def followers
    QuestionFollow.followers_for_question_id(id)
  end

  private
  attr_reader :id

end

class QuestionFollow

  def self.all
    data = QuestionsDatabase.instance.execute(
      "SELECT * FROM question_follows"
    )
    data.map { |datum| QuestionFollow.new(datum) }
  end

  def self.followers_for_question_id(question_id)
    question_followers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT fname, lname
      FROM question_follows 
      JOIN users ON question_follows.user_id = users.id
      WHERE question_id = ? 
    SQL

    question_followers.map { |datum| User.new(datum) }

  end

  def self.followed_questions_for_user_id(user_id)
    followed_questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT title, body, author
      FROM question_follows
      JOIN questions ON question_follows.question_id = questions.id
      WHERE author = ?
    SQL

    followed_questions.map { |datum| Question.new(datum) }
  end

  def self

  def initialize(question_follows_data)
    @question_id = question_follows_data["question_id"]
    @user_id = question_follows_data["user_id"]
  end
end


class Reply
  def self.all
    data = QuestionsDatabase.instance.execute(
      "SELECT * FROM replies"
    )
    data.map { |datum| Reply.new(datum) }
  end

  def self.find_by_user_id(user_id)
    QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT * FROM replies WHERE user_id = ?
    SQL
  end

  def self.find_by_question_id(question_id)
    QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT * FROM replies WHERE question_id = ?
    SQL
  end

  def initialize(reply_data)
    @id = reply_data["id"]
    @body = reply_data["body"]
    @question_id = reply_data["question_id"]
    @user_id = reply_data["user_id"]
    @parent_id = reply_data["parent_id"]
  end

  def author
    QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT fname, lname 
      FROM replies
      JOIN users 
      ON replies.user_id = users.id
      WHERE users.id = ?
    SQL
  end

  def question
    QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT DISTINCT questions.body FROM replies
      JOIN questions ON replies.question_id = questions.id
      WHERE questions.id = ?
    SQL
  end

  def parent_reply
    QuestionsDatabase.instance.execute(<<-SQL, parent_id)
      SELECT body
      FROM replies
      WHERE id = ?
    SQL
  end

  def child_reply
    QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT body 
    FROM replies
    WHERE parent_id = ?
    SQL
  end

  private
  attr_reader :id, :user_id, :question_id, :parent_id
end

class QuestionLike
  def self.all
    data = QuestionsDatabase.instance.execute(
      "SELECT * FROM question_likes"
    )
    data.map { |datum| QuestionLike.new(datum) }
  end

  def initialize(like_data)
    @question_id = like_data["question_id"]
    @use_id = like_data["user_id"]
  end
end
