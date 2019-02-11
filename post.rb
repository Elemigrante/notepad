require 'sqlite3'

class Post

  @@SQLITE_DB_FILE = 'notepad.sqlite'

  def self.post_types
    { 'Memo' => Memo, 'Link' => Link, 'Task' => Task }
  end

  def self.create(type)
    post_types[type].new
  end

  def self.find(limit, type, id)
    db = SQLite3::Database.open(@@SQLITE_DB_FILE)

    #  1. конкретная запись
    if !id.nil?
      db.results_as_hash = true

      result = db.execute("SELECT * FROM posts WHERE rowid = ?", id)
      result = result[0] if result.is_a? Array

      db.close

      if result.empty?
        puts "Такой id #{id} не найден в базе :("
        nil
      else
        post = create(result['type'])

        post.load_data(result)

        post
      end
    else
    #  2. вернуть таблицу записей
    end
  end

  def initialize
    @created_at = Time.now
    @text = nil
  end

  def read_from_console
  end

  def to_strings
  end

  def save
    file = File.new(file_path, 'w:UTF-8')

    to_strings.each { |string| file.puts(string) }
    file.close
  end

  def file_path
    current_path = File.dirname(__FILE__)

    file_name = @created_at.strftime("%Y-%m-%d_%H-%M-%S.txt")

    "#{current_path}/#{self.class.name}_#{file_name}.txt"
  end

  def save_to_db
    db = SQLite3::Database.open(@@SQLITE_DB_FILE)
    db.results_as_hash = true

    db.execute(
      "INSERT INTO posts (" +
        to_db_hash.keys.join(',') +
        ")" +
        " VALUES (" +
        ('?,' * to_db_hash.keys.size).chomp(',') +
        ")",
      to_db_hash.values
    )

    insert_row_id = db.last_insert_row_id

    db.close

    insert_row_id # return
  end

  def to_db_hash
    {
      'type' => self.class.name,
      'create_at' => @created_at.to_s
    }
  end

  # получает на вход хэш массив данных и должен заполнить свои поля
  def load_data(data_hash)
    @created_at = Time.parse(data_hash['create_at'])
  end
end