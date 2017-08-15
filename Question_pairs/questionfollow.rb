require_relative 'questions_db'
require_relative 'user'
require_relative 'question'

class QuestionFollow
  attr_accessor :user_id, :question_id
  attr_reader :id

  def self.all
    data = QuestionsDatabase.instance.execute('SELECT * FROM question_follows')
    data.map { |el| QuestionFollow.new(el) }
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  def self.find_by_id(id)
    follow = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT *
      FROM question_follows
      WHERE id = ?
    SQL
    raise "not in users database" if follow.empty?
    follow.map { |f| QuestionFollow.new(f) }.first
  end

  def self.followers_for_question_id(question_id)
    users = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT *
      FROM question_follows
      JOIN users
        ON users.id = question_follows.user_id
      WHERE question_id = ?
    SQL
    raise '#{self} has no followers!' if users.empty?
    users.map {|u| User.new(u) }
  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT *
      FROM question_follows
      JOIN questions
        ON questions.id = question_follows.question_id
      WHERE user_id = ?
    SQL
    raise '#{self} has no followed questions!' if questions.empty?
    questions.map {|q| Question.new(q) }
  end

  def create
    raise '#{self} is already a follow!' if @id
    QuestionsDatabase.instance.execute(<<-SQL, @user_id, @question_id)
      INSERT INTO replies(user_id, question_id)
      VALUES (?, ?, ?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

end
