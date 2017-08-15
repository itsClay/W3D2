require_relative 'questions_db.rb'

class Reply
  attr_accessor :question_id, :parent_reply_id, :body, :user_id
  attr_reader :id

  def self.all
    data = QuestionsDatabase.instance.execute('SELECT * FROM replies')
    data.map { |el| Reply.new(el) }
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @parent_reply_id = options['parent_reply_id']
    @body = options['body']
    @user_id = options['user_id']
  end

  def self.find_by_id(id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT *
      FROM replies
      WHERE id = ?
    SQL
    raise "not in replies database" if reply.empty?
    reply.map {|r| Reply.new(r) }.first
  end

  def self.find_by_user_id(user_id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT *
      FROM replies
      WHERE user_id = ?
    SQL
    raise "not in replies database" if reply.empty?
    reply.map {|r| Reply.new(r) }
  end

  def self.find_by_question_id(question_id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT *
      FROM replies
      WHERE question_id = ?
    SQL
    raise "not in replies database" if reply.empty?
    reply.map {|r| Reply.new(r) }
  end

  def author
    name = QuestionsDatabase.instance.execute(<<-SQL, @user_id)
      SELECT *
      FROM users
      WHERE id = ?
    SQL
    raise "not in replies database" if name.empty?
    name.map { |n| User.new(n) }
  end

  def question
    question = QuestionsDatabase.instance.execute(<<-SQL, @question_id)
      SELECT *
      FROM questions
      WHERE id = ?
    SQL
    raise "not in replies database" if name.empty?
    question.map { |q| Question.new(q) }
  end

  def parent_reply
    reply = QuestionsDatabase.instance.execute(<<-SQL, @parent_reply_id)
      SELECT *
      FROM replies
      WHERE id = ?
    SQL
    return nil if reply.empty?
    reply.map { |r| Reply.new(r) }
  end

  def child_replies
    reply = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT *
      FROM replies
      WHERE parent_reply_id = ?
    SQL
    return nil if reply.empty?
    reply.map { |r| Reply.new(r) }
  end

  def create
    raise '#{self} is already a reply!' if @id
    QuestionsDatabase.instance.execute(<<-SQL, @question_id, @parent_reply_id, @body, @user_id)
      INSERT INTO replies(question_id, parent_reply_id, body, user_id)
      VALUES (?, ?, ?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end
end
