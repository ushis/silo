namespace :attachments do

  task check: :environment do
    db = Attachment.pluck(:filename)
    fs = Attachment::STORE.children(false).collect { |p| p.to_s }
    diff = [db - fs, fs - db]

    if diff.all? { |d| d.size == 0 }
      puts "Found #{db.size} files and no errors."
      next
    end

    puts 'Files in database, but not on filesystem'
    puts '========================================'
    puts diff[0]
    puts '========================================'
    puts "#{diff[0].size}/#{db.size}\n\n"

    puts 'Files on filesystem, but not in database'
    puts '========================================'
    puts diff[1]
    puts '========================================'
    puts "#{diff[1].size}/#{fs.size}"
  end
end
