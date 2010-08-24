class Project
  Grit.debug = true
  
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
    Dir.chdir(path) do
      repo.status.untracked.map do |file, status|
        repo.add(file)
      end
      
      repo.commit_all(message) or raise CommitError, "cannot commit all files"
    end
  end
  
  def status
    repo.status
  end
  
  private
  def repo
    @repo ||= Grit::Repo.new(path)
  end
end