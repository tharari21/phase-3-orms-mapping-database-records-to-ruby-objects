class Song

  attr_accessor :name, :album, :id

  def initialize(name:, album:, id: nil)
    @id = id
    @name = name
    @album = album
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS songs
    SQL

    DB[:conn].execute(sql)
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS songs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        album TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO songs (name, album)
      VALUES (?, ?)
    SQL

    # insert the song
    DB[:conn].execute(sql, self.name, self.album)

    # get the song ID from the database and save it to the Ruby instance
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM songs")[0][0]

    # return the Ruby instance
    self
  end

  def self.create(name:, album:)
    song = Song.new(name: name, album: album)
    song.save
  end
  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], album: row[2])
  end
  def self.all
    # This will return an array of rows from the database that matches our query. 
    # Now, all we have to do is iterate over each row and use the self.map method 
    # to create a new Ruby object for each row:
    DB[:conn].execute('SELECT * FROM songs').map do |row|
      self.new_from_db(row)
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM songs
      WHERE name = ?
      LIMIT 1
    SQL
    # Don't be freaked out by that #first method chained to the end of the DB[:conn].execute(sql, name).map block. The return value of the #map method is an array, and we're simply grabbing the #first element from the returned array. Chaining is cool!
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

end
