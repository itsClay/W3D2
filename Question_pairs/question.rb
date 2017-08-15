require_relative 'questions_db.rb'

class Question
  attr_accessor :title, :body, :author_id
  attr_reader :id

  def self.all
    data = QuestionsDatabase.instance.execute('SELECT * FROM questions')
    data.map { |el| Question.new(el) }
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

  def self.find_by_id(id)
    question = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT *
      FROM questions
      WHERE id = ?
    SQL
    raise "not in questions database" if question.empty?
    question.map {|q| Question.new(q) }.first
  end

  def self.find_by_author_id(author_id)
    question = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT *
      FROM questions
      WHERE
        author_id = ?
    SQL
    raise "not in questions database" if question.empty?
    question.map {|q| Question.new(q) }
  end

  def author
    name = QuestionsDatabase.instance.execute(<<-SQL, @author_id)
      SELECT *
      FROM users
      WHERE id = ?
    SQL
    raise "not in questions database" if name.empty?
    name.map { |n| User.new(n) }
  end

  def replies
    Reply.find_by_question_id(@id)
  end

  def create
    raise '#{self} is already a question!' if @id
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @author_id)
      INSERT INTO questions(title, body, author_id)
      VALUES (?, ?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end
end
