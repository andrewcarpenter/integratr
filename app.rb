require 'rubygems'
require 'sinatra'
require 'erb'
require 'grit'

require 'project'

get '/' do
  redirect '/projects'
end

get '/projects' do
  @title = "All Projects"
  @projects = Project.all
  erb :index
end

get '/projects/:project_slug' do
  @project = Project.find(params[:project_slug]) or raise Sinatra::NotFound
  @title = "Project: #{@project.name}"
  erb :show
end

post '/projects/:project_slug/commits' do
  @project = Project.find(params[:project_slug]) or raise Sinatra::NotFound
  
  commit_message = params[:message]
  if commit_message && commit_message != ''
    @project.add_and_commit_all!(commit_message)
    @project.push!
    redirect "/projects/#{@project.slug}"
    erb :show
  else
    @title = "Project: #{@project.name}"
    @error_message = "You must enter a message to commit."
    erb :show
  end
end

error Project::CommitError do
  'Something bad happened while attempting to commit: ' + request.env['sinatra.error'].message
end