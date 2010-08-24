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
    `cd #{path} && git push origin integration` # TODO add error handling
  end
  
  def untracked_files
    repo.status.untracked.map{|path, status| path}.reject do |path|
      ignore_patterns.any?{|pattern| File.fnmatch?( pattern, path )}
    end
  end
  
  def changed_files
    repo.status.changed.map{|path, status| path}
  end
  
  private
  
  def repo
    @repo ||= Grit::Repo.new(path)
  end
  
  def ignore_patterns
    @ignore_patterns ||= File.read(File.join(path, '.gitignore')).  # read the gitignore file
        to_a.                                                       # convert to array of lines
        map{|p| p.sub(/^#.*/, '')}.                                 # remove comments
        compact.                                                    # remove nils
        map{|p| p.chomp}.
        reject{|p| p == ''}                                         # remove empty lines
  end
end