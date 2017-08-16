require_relative 'questions_db'
require_relative 'user'
require_relative 'question'

class QuestionLike
  attr_accessor :user_id, :question_id
  attr_reader :id

  def self.all
    data = QuestionsDatabase.instance.execute('SELECT * FROM question_likes')
    data.map { |el| QuestionLike.new(el) }
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  def self.find_by_id(id)
    like = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT *
      FROM question_likes
      WHERE id = ?
    SQL
    raise "not in likes database" if like.empty?
    like.map { |l| QuestionLike.new(l) }.first
  end

  def self.likers_for_question_id(question_id)
    liker = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT *
      FROM question_likes
      JOIN users
        ON users.id = question_likes.user_id
      WHERE question_id = ?
    SQL
    raise 'This question has no likers!' if liker.empty?
    liker.map {|l| User.new(l) }
  end

  def self.num_likes_for_question_id(question_id)
    count = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT COUNT(user_id)
      FROM question_likes
      WHERE question_id = ?
      GROUP BY question_id
    SQL
    return 0 if count.empty?
    count.first.values.first
  end

  def self.liked_questions_for_user_id(user_id)
    question = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT q.id, q.title, q.body, q.author_id
      FROM question_likes
      JOIN questions as q
        ON q.id = question_likes.question_id
      WHERE user_id = ?
    SQL
    raise 'This user has no liked questions!' if question.empty?
    question.map {|q| Question.new(q) }
  end

  def self.most_liked_questions(n)
    questions = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT q.id, q.title, q.body, q.author_id
      FROM question_likes
      JOIN questions as q
        ON question_likes.question_id = q.id
      GROUP BY question_id
      ORDER BY COUNT(user_id) DESC
      LIMIT ?
    SQL
    raise 'not one question has been liked!' if questions.empty?
    questions.map {|q| Question.new(q) }
  end

  def create
    raise '#{self} is already a like!' if @id
    QuestionsDatabase.instance.execute(<<-SQL, @user_id, @question_id)
      INSERT INTO question_likes(user_id, question_id)
      VALUES (?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end
end
