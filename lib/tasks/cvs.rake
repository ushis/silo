require 'pathname'
require 'colorize'

namespace :cvs do
  task :import, [:cvdir, :refs, :shifts] => [:environment] do |task, args|
    cvs = Dir[File.join(args[:cvdir], '*')]
    trash = Pathname.new(File.join('/tmp', 'silo-cvs'))
    len = cvs.size
    refs, old_refs = [{}, {}]
    langs = { 'd' => :de, 'f' => :fr, 's' => :es, 'p' => :pt }

    puts "Loading references: #{args[:refs]}"

    File.open(args[:refs]) do |f|
      f.each do |line|
        index, filename = line.chomp.split(':')
        old_refs[filename] = index
      end
    end

    puts "Loding shifts: #{args[:shifts]}"

    File.open(args[:shifts]) do |f|
      f.each do |line|
        index, id = line.chomp.split(':')

        old_refs.each do |filename, i|
          refs[filename] = id if index == i
        end
      end
    end

    trash.rmtree if trash.exist?
    trash.mkpath

    cvs.each_with_index do |cv, i|
      base = File.basename(cv)
      puts "[#{i + 1}/#{len}] Processing: #{base}".blue

      if (id = refs[base]).nil? || ! (e = Expert.find_by_id(id))
        puts "=> Expert not found for: #{base}".red
        FileUtils.cp(cv, trash.join(base))
        next
      end

      lang = :en

      if (a = /_([a-z])(?:\.|_)/.match(base))
        lang = langs[a[1]] || :en
      end

      f = File.open(cv)

      if e.cvs.build(file: f, language: lang).save_or_destroy
        f.close
        next
      end

      puts "=> Could not load cv: #{base}".red
      puts "=> Storing as attachment".yellow

      f.rewind

      if e.attachments.build(file: f).save_or_destroy
        f.close
        next
      end

      puts "=> Could not store attachment: #{base}".red
      FileUtils.cp(cv, trash.join(base))
    end
  end
end
