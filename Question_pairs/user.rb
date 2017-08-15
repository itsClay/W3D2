require_relative 'questions_db'
require_relative 'question'
require_relative 'reply'

class User
  attr_accessor :fname, :lname
  attr_reader :id

  def self.all
    data = QuestionsDatabase.instance.execute('SELECT * FROM users')
    data.map { |el| User.new(el) }
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def self.find_by_id(id)
    user = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT *
      FROM users
      WHERE id = ?
    SQL
    raise "not in users database" if user.empty?
    user.map {|person| User.new(person) }.first
  end

  def self.find_by_name(fname, lname)
    user = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT *
      FROM users
      WHERE
        fname = ? AND
        lname = ?
    SQL
    raise "not in users database" if user.empty?
    user.map {|person| User.new(person) }
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def create
    raise '#{self} is already a user!' if @id
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)
      INSERT INTO users(fname, lname)
      VALUES (?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end
end
