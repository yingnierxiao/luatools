--
-- Author: Your Name
-- Date: 2015-05-27 14:19:33
--
local util = require("util")
local xml = require("xml")


local cmd = "TexturePacker %s.pvr.ccz --sheet %s.png --algorithm Basic --allow-free-size --no-trim --max-size 4048"


local pvrExt = ".pvr.ccz"
local plistExt = ".plist"
local pngExt = ".png"
local xmlExt =".local.xml"

function pvr2pngFile( filePath )
	local fileinfo = util.pathinfo(filePath)
	if fileinfo.extname == pvrExt then 
		local newFilename = fileinfo.dirname..fileinfo.basename
		os.execute(string.format(cmd, newFilename,newFilename))
		util.rmfile(filePath)
	end
end


function repFileString( filePath )
	local fileinfo = util.pathinfo(filePath)
	if fileinfo.extname == plistExt then 
		util.filegsub(filePath,pvrExt,pngExt)
	end
end


local cut = "convert %s -crop %sx%s+%s+%s %s"
local rotate="convert %s -rotate -90 %s"
function splitPlist2Images( filePath )
	local fileinfo = util.pathinfo(filePath)
	if fileinfo.extname == plistExt then 
		local xmlData = xml.loadpath(filePath)
		-- util.trace(xmlData)

		local images = xmlData[1][2]
		
		local image = xmlData[1][4][4][1]
		local imageName 
		local imageRect 
		local isRot

		-- util.trace(images)
		for i,v in ipairs(images) do
			if i%2==1 then 
				imageName = v[1]
			else
				imageRect = v[2][1]
				isRot = v[6]["xml"]
				imageRect = imageRect:gsub("{",""):gsub("}","")
				
				local rect = string.split(imageRect, ",")
				local rot = ""
				if isRot =="true" then 
					local temp = rect[3]
					rect[3]=rect[4]
					rect[4]=temp
					-- rot = rotate
				end

				local cmd = string.format(cut,fileinfo.dirname..image,tonumber(rect[3])+4,tonumber(rect[4])+4,tonumber(rect[1])-1,tonumber(rect[2])-1,fileinfo.dirname..imageName)
				os.execute(cmd)
				if isRot =="true" then 
					os.execute(string.format(rotate, fileinfo.dirname..imageName,fileinfo.dirname..imageName))
				end
			end
			
		end
		os.exit()
	end
	
end

function splitXml( filePath )
	local fileinfo = util.pathinfo(filePath)
	print(fileinfo.extname)
	if fileinfo.extname == xmlExt then 
		local xmlData = xml.loadpath(filePath)
		-- util.trace(xmlData[1])
		for i,v in ipairs(xmlData) do
			print("\n")
			util.trace(v,v["id"])
		end
	end
end



-- util.scanDir("/Users/zj/Desktop/cok",10,filterFile)
-- util.scanDir("/Users/zj/Desktop/cok",10,splitPlist2Images)
splitXml("/Users/zj/Desktop/cok/local/database.local.xml")