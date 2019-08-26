require_relative "../config/environment.rb"

class Student
  attr_accessor :id, :name, :grade
  
  def initialize(name, grade, id = nil)
    @name, @grade, @id = name, grade, id
  end

  def self.new_from_db(row)
    student = self.new(row[1], row[2], row[0])
    student
  end

  def self.all
    DB[:conn].execute("SELECT * FROM students").map { |row| new_from_db row }
  end
  
  def self.all_students_in_grade_9
    all.select { |student| student.grade == '9' }
  end
  
  def self.students_below_12th_grade
    all.select { |student| student.grade.to_i < 12 }
  end
  
  def self.first_X_students_in_grade_10(x)
    all.select { |student| student.grade == '10' }
       .take(x)
  end
  
  def self.first_student_in_grade_10
    first_X_students_in_grade_10(1).first
  end
  
  def self.all_students_in_grade_X(x)
    all.select { |student| student.grade.to_i == x }
  end

  def self.find_by_name(name)
    result = DB[:conn].execute("SELECT * FROM students WHERE name = ?", name)
    unless result.empty?
      new_from_db(result.first)
    else
      nil
    end
  end
  
  def self.create(name, grade)
    student = new(name, grade)
    student.save
    student
  end
  
  def update
    save
  end
  
  def save
    if @id.nil?
      sql = <<-SQL
        INSERT INTO students (name, grade) 
        VALUES (?, ?)
      SQL
  
      DB[:conn].execute(sql, self.name, self.grade)
      
      @id = DB[:conn].execute("SELECT id FROM students WHERE name = ?", @name).first.first
    else
      sql = <<-SQL
      UPDATE students SET name = ?, grade = ?
      WHERE id = ?
      SQL
      
      DB[:conn].execute(sql, self.name, self.grade, self.id)
    end
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
