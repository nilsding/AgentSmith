module AgentSmith
  module IRC
    class User
      include Comparable(User)

      getter matrix_id : String,
        ident_s : String,
        nickname : String,
        hostname : String,
        presence = false,

        def initialize(@matrix_id)
          @ident_s = self.class.matrix_id_to_ident(@matrix_id)
          @nickname = self.class.matrix_id_to_nickname(@matrix_id)
          @hostname = self.class.matrix_id_to_hostname(@matrix_id)
        end

      def_hash @matrix_id

      # converts a matrix id in the format of `@nilsding:rrerr.net` to
      # `nilsding!nilsding@rrerr.net`
      def self.matrix_id_to_ident(matrix_id) : String
        matrix_id.sub(/@([^:]+):(.+)/, "\\1!\\1@\\2", backreferences: true)
      end

      # converts a matrix id in the format of `@nilsding:rrerr.net` to
      # `nilsding`
      def self.matrix_id_to_nickname(matrix_id) : String
        matrix_id.sub(/@([^:]+):.+/, "\\1", backreferences: true)
      end

      # converts a matrix id in the format of `@nilsding:rrerr.net` to
      # `nilsding`
      def self.matrix_id_to_hostname(matrix_id) : String
        matrix_id.split(":").last
      end

      def <=>(other)
        self.matrix_id <=> other.matrix_id
      end
    end
  end
end
