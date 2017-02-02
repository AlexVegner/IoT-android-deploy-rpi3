require 'rake'

IMAGE_ZIP_URL = "https://dl.google.com/dl/androidthings/rpi3/devpreview/1/androidthings_rpi3_devpreview_1.zip"
IMAGE_ZIP_FILE = "androidthings_rpi3_devpreview_1.zip"
IMAGE_FILE = "iot_rpi3.img"

disk_number = ARGV[0].dup

unless disk_number && (!!Integer(disk_number) rescue false) && disk_number.to_i > 2
  system('diskutil list')
  abort "Please enter /dev/disk(n) number and should be more then 2"
end

def cmd(command, title: "", error: "the operation failed")
  if title
    puts "\# #{title}"
  end
  sh command do |ok, res|
     if !ok
       abort error
     end
  end
end

# Download Raspbery image
unless File.file?(IMAGE_FILE)
  command = "curl -O #{IMAGE_ZIP_URL}"
  cmd(command, title: "Download image")

  # Unzip image
  command = "unzip -j #{IMAGE_ZIP_FILE}"
  cmd(command, title: "Unzip image")

  # Delete zip
  command = "rm #{IMAGE_ZIP_FILE}"
  cmd(command, title: "Delete zip")
end

# Format disk with FAT32
command = "diskutil eraseDisk FAT32 RPI /dev/disk#{disk_number}"
cmd(command, title: "Formatting disk#{disk_number}")

# Unmount disk
command = "diskutil unmountDisk /dev/disk#{disk_number}"
cmd(command, title: "Unmount drive")

# Flash image
command = "sudo dd bs=1m if=#{IMAGE_FILE} of=/dev/rdisk#{disk_number}"
cmd(command, title: "Flash image")

# Eject disk
command = "diskutil eject disk#{disk_number}"
cmd(command, title: "Eject disk")

puts '----- OPERATION COMPLITED ------'
