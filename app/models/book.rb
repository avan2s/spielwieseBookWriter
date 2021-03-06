class Book < ActiveRecord::Base

  attr_accessible :title, :edition, :published, :genre, :abstract, :tags, :user_ids, :closed

  has_and_belongs_to_many :users
  has_many :chunks

  validates_presence_of :title, :edition
  validates :edition, :uniqueness => {:scope => :title}
  validate :at_least_one_user_ids_selected
  before_destroy :destroy_chunks

  def self.search(search)
    if search
      where('title LIKE ?', "%#{search}%")
    else
      scoped
    end
  end

  def sliced_attributes
    attributes.slice('title', 'genre', 'abstract', 'tags')
  end

  def published?
    !published.nil?
  end

  def has_chunks?
    !chunks.empty?
  end

  def max_chunk_position
    has_chunks? ? chunks.max_by(&:position).position : 0
  end

  def users_list
    users.collect { |u| u.username }.join(',')
  end

  def users_list_real_names
    users.collect { |u| u.first_name + ' ' + u.last_name }.join(',')
  end

  private
  def destroy_chunks
    chunks.each do |chunk|
      chunk.destroy
    end
  end

  #TODO add german error message and highlight the checkboxes and email fields
  def at_least_one_user_ids_selected
    if self.user_ids.blank?
      self.errors.add(:user_ids, "no_autor_selectet")
    end
  end

end