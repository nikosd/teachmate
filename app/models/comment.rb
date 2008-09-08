class Comment < ActiveRecord::Base

  belongs_to :user
  validates_presence_of :body

  class <<self
    def find_for_user(user_id)
      
      comments     = User.find(user_id).comments
      author_ids   = comments.map {|s| s.author_id} 
      authors = User.find(:all, :conditions => ['id in (?)', author_ids])
      
      result = []
      comments.each do |c|
        
        author = nil
        authors.each do |a|
          author = a if a.id == c.author_id
        end

        result.push(
          {
            :author => author,
            :element => c
          }
        ) if author
      end
      result 
    
    end
  end

end
