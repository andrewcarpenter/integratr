class Project
  class CommitError < StandardError; end
  def self.all
    data = YAML.load( File.open(File.join(File.dirname(__FILE__), 'projects.yml') ) )
    data.to_a.map do |slug, options|
      new(slug, options)
    end
  end
  
  def self.find(slug)
    all.find{|project| project.slug == slug.to_sym}
  end
  
  attr_accessor :slug, :path, :name
  def initialize(slug, options)
    @slug = slug.to_sym
    @path = options['path']
    @name = options['name']
  end
  
  def add_and_commit_all!(message)
    repo.add(repo.status.untracked.map{|file, status| file }) or raise CommitError, "cannot add all files"
    repo.commit_all(message) or raise CommitError, "cannot commit all files"
  end
  
  def status
    repo.status
  end
  
  private
  def repo
    @repo ||= Grit::Repo.new(path)
  end
end