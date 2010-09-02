require 'yaml'
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
      untracked_files.map do |file, status|
        repo.add(file)
      end
      
      repo.commit_all(message) or raise CommitError, "cannot commit all files"
    end
  end
  
  def push!
    `cd #{path} && /usr/local/bin/git push origin integration` # TODO add error handling
  end
  
  def checkout!
    untracked_files.each do |file_name|
      File.delete(File.join(path, file_name))
    end
    `cd #{path} && /usr/local/bin/git checkout .`
  end
  
  def untracked_files
    `cd #{path} && git ls-files --others --exclude-standard`.to_a.map(&:chomp)
  end
  
  def changed_files
    repo.status.changed.map{|path, status| path}
  end
  
  def deleted_files
    repo.status.deleted.map{|path, status| path}
  end
  
  def recent_commits
    repo.commits('integration')
  end
  
  private
  
  def repo
    @repo ||= Grit::Repo.new(path)
  end
end