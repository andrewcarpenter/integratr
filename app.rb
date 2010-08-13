require 'rubygems'
require 'sinatra'
require 'erb'
require 'grit'

require 'project'

get '/' do
  redirect '/projects'
end

get '/projects' do
  @projects = Project.all
  erb :index
end

get '/projects/:project_slug' do
  @project = Project.find(params[:project_slug]) or raise Sinatra::NotFound
  erb :show
end

post '/projects/:project_slug/commits' do
  @project = Project.find(params[:project_slug]) or raise Sinatra::NotFound
  
  commit_message = params[:message]
  if commit_message && commit_message != ''
    result = @project.add_and_commit_all!(commit_message)
    @notice_message = "Successfully committed!<pre>" + result + "</pre>"
    erb :show
  else
    @error_message = "You must enter a message to commit."
    erb :show
  end
end

error Project::CommitError do
  'Something bad happened while attempting to commit: ' + request.env['sinatra.error'].message
end