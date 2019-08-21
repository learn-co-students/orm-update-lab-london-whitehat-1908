class Student
  attr_accessor :id, :name, :grade

  def self.create(name, grade)
    stud = Student.new(name, grade)
    stud.save
  end

  def update
    self.save
  end

  def self.new_from_db(row)
    # create a new Student object given a row from the database
    stud = Student.new(row[1], row[2], row[0])
    stud
  end

  def initialize(name, grade, id=nil)
    @id = id
    @name = name
    @grade = grade
  end



  def self.all
    # retrieve all the rows from the "Students" database
    # remember each row should be a new instance of the Student class
    sql = <<-SQL
            SELECT * FROM students
          SQL
    DB[:conn].execute(sql).map do |row|
      self.new_from_db(row)
    end
  end

  def self.all_students_in_grade_9
    sql = <<-SQL
            SELECT * FROM students
            WHERE grade = 9
          SQL
    DB[:conn].execute(sql)
  end

  def self.students_below_12th_grade
    sql = <<-SQL
            SELECT * FROM students
            WHERE grade < 12
          SQL
    DB[:conn].execute(sql).map do |row|
      self.new_from_db(row)
    end
  end

   def self.all_students_in_grade_X(grade)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE grade = ?
      ORDER BY students.id
    SQL

    DB[:conn].execute(sql, grade).map do |row|
      self.new_from_db(row)
    end
  end

    def self.first_X_students_in_grade_10(number)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE grade = 10
      ORDER BY students.id
      LIMIT ?
    SQL

    DB[:conn].execute(sql, number).map do |row|
      self.new_from_db(row)
    end
  end

  def self.first_student_in_grade_10
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE grade = 10
      ORDER BY students.id LIMIT 1
    SQL

    DB[:conn].execute(sql).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first
  end
  
  def save
    id_temp = (id_temp == nil) ? 1 : nil
    DB[:conn].execute("INSERT OR REPLACE INTO students VALUES ( COALESCE((SELECT id FROM students WHERE id=?),?),?,?);", id_temp, id_temp, @name, @grade)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
  end
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end
end
