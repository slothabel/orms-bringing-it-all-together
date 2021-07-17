require 'pry'
class Dog
    attr_accessor :name, :breed, :id

    def initialize(id: nil, name:, breed:)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL 
        CREATE TABLE IF NOT EXISTS dogs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT
          )
          SQL
          DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)
    end

    def save
        if self.id 
        self.update 
        else 
        sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end
      
    
    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.create(name:, breed:)
        puppy = Dog.new(name: name, breed: breed)
        puppy.save
        puppy
    end

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end
        
    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1"
        DB[:conn].execute(sql, id).map {|row| self.new_from_db(row)}.first
    end

    def self.find_or_create_by(name:, breed:)
        puppy = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !puppy.empty?
          puppy_info = puppy[0]
          puppy = Dog.new(id: puppy_info[0], name: puppy_info[1], breed: puppy_info[2])
        else
            puppy = self.create(name: name, breed: breed)
        end
        puppy
      end 

      def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
        DB[:conn].execute(sql, name).map {|row| self.new_from_db(row)}.first
      end





end
