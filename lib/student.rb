require_relative "../config/environment.rb"

class Student

  attr_accessor :id, :grade, :name

  def initialize(name, grade, id = nil)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table 
    sql =  <<-SQL 
      CREATE TABLE IF NOT EXISTS students (
        id NOT NULL PRIMARY KEY,
        name TEXT,
        grade TEXT
      )
    SQL
    DB[:conn].execute(sql) 
  end

  def self.drop_table
    sql =  <<-SQL 
    DROP TABLE students
    SQL
    DB[:conn].execute(sql) 
  end

  def save 
    if self.id then 
      self.update
    else
      sql =  <<-SQL 
      INSERT INTO students (name, grade)
      VALUES (?,?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade) 
      
      sql =  <<-SQL 
        SELECT last_insert_rowid() 
        FROM students
      SQL
      self.id = DB[:conn].execute(sql) [0][0]
    end
  end

  def self.create(name, grade) 
    sql =  <<-SQL 
      INSERT INTO students (name, grade)
      VALUES (?,?)
    SQL
    DB[:conn].execute(sql, name, grade)
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    grade = row[2]
    self.new(name, grade, id)
  end

  def self.find_by_name(name)
    sql =  <<-SQL 
      SELECT *
      FROM students
      WHERE name = ?
    SQL
    arr = DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql =  <<-SQL 
      UPDATE students 
      SET id = ?, name = ?, grade = ?
    SQL
    DB[:conn].execute(sql, self.id, self.name, self.grade)
  end

end
