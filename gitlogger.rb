require 'csv'
class GitLogger
  attr_accessor :project, :commit_date, :activity, :author
end

logs = []
repo_paths = Dir["/var/apps/*"]

repos = repo_paths.map do |repo|
  {name: repo.split("/")[3], path: repo}
end

# Builds log files
repos.each do |repo|
  `cd #{repo[:path]} && git log --author \"Scott Helm\" --since \" 3 weeks ago \" > /tmp/repo_log_#{repo[:name]}`
end

#Processes log files
repos.each do |repo|
  log = nil
  f = File.open("/tmp/repo_log_#{repo[:name]}", "r").each_line do |line|
    if line
      if line =~ /^commit/
        log = GitLogger.new
        log.project = repo[:name]

      elsif line =~ /^Author/
        log.author = line.split("Author: ")[1].to_s.strip

      elsif line =~ /^Date/
        log.commit_date = Date.parse(line.split("Date: ")[1].to_s.strip).to_s

      elsif line.strip! != ""
        log.activity = line
        logs << log
      end
    end
  end
end

output = CSV.generate do |csv|
  csv << ["project", "commit_date", "activity", "author"]
  logs.each do |log|
    csv << [log.project, log.commit_date, log.activity, log.author]
  end
end

File.open("./my_gitlogs.csv", "w+") {|f|  f.write(output) }

`ls /tmp/repo_log* | xargs rm`

puts "open this:"
puts "~/my_gitlogs.csv"

