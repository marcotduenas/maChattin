require "socket"
class Server
  def initialize( port, ip )
    @server = TCPServer.open( ip, port )
    @connections = Hash.new
    @rooms = Hash.new
    @users = Hash.new
    @connections[:server] = @server
    @connections[:rooms] = @rooms
    @connections[:users] = @users
    run
  end

  def run
    loop {
      Thread.start(@server.accept) do | user |
        nick_name = user.gets.chomp.to_sym
        @connections[:users].each do |other_name, other_user|
          if nick_name == other_name || user == other_user
            user.puts "This username already exist"
            Thread.kill self
          end
        end
        puts "#{nick_name} #{user}"
        @connections[:users][nick_name] = user
        user.puts "Connection established, Be Welcome"
        listen_user_messages( nick_name, user )
      end
    }.join
  end

  def listen_user_messages( username, user )
    loop {
      msg = user.gets.chomp
      @connections[:users].each do |other_name, other_users|
        unless other_name == username
          other_users.puts "#{username.to_s}: #{msg}"
        end
      end
    }
  end
end

Server.new( 3000, "localhost" )