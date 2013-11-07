--[[
    Support menus
    Make informational screens: Health, Abilities.

    @version 1.0.2, BIT
    @author  Hellkid98, HK98
    @author  TheOriginalBIT, BIT
--]]

--# make sure required APIs are loaded before to avoid errors as much as possible
assert(utils, "GUI API must be loaded after the Utils API", 0)








--[[ Drawing functions ]]--

--[[
    @description    "Draws text at the specified position"
	
	
	@param          x,    xPosition
	@param          y,    yPositon
	
	@return         nil,
--]]
function drawAt(x,y,text)
    term.setCursorPos(x,y) 
	write(text)
end
 
 
--[[
    @description    "Clears the screen, Fills it with a color if inputted"
	
	
	@param          bColor,    number
	
	@return         nil,
--]]
function clear(bColor)
    if bColor ~= nil then
	    term.setBackgroundColor(bColor)
	end
    term.clear()
    term.setCursorPos(1,1)
end

 
--[[
    @description    "Draws a box from starting value to finish values"
	
	
	@param          sX,    number
	@param          fX,    number
	@param          sY,    number
	@param          fY,    number
	@param      bColor,    color
	
	@return        nil
--]]
function drawBox(sX,fX,sY,fY,bColor)

    if bColor ~= nil then
        term.setBackgroundColor(bColor)
	else
	    error("nil bColor",2)
    end

	
        local str = ""
		
    for x = sX, fX do
        str = str.." "
    end
	
   for y = sY, fY do
       drawAt(sX,y,str)
   end
   
end   
   
  
--[[
    @description    "Draws a single line at the y position"
	
	
	@param          sX,    number
	@param          fX,    number
	@param           y,    number
	@param      tColor,    color or nil
	@param      bColor,    color or nil
	@param          ch,    string or nil
	
	@return        nil
--]]
function drawLine(sX,fX,y,tColor,bColor,ch)
 
    if ch == nil then
        ch = " "
    end
 
    if tColor ~= nil then
        term.setTextColor(tColor)
    end
 
    if bColor ~= nil then
        term.setBackgroundColor(bColor)
    end
 
        local str = "" 
		
    for x = sX, fX do
        str = str..ch 
    end
        drawAt(sX,y,str)
end


--[[
    @description    "Centers and draws text at the desired yPosition"
	
	
	@param          y,    number
	@param     tColor,    color or nil
	@param     bColor,    color or nil
	@param       text,    string
	
	@return       nil
--]]
function centerPrint(y,tColor,bColor,text)
    if tColor ~= nil then
        term.setTextColor(tColor)
    end
   
    if bColor ~= nil then
        term.setBackgroundColor(bColor) 
    end	
	
	if text == nil then 
	    error("text was nil",2) 
	end
	
        term.setCursorPos(math.ceil(w/2 - #text/2),y)
        write(text)
end








--[[ Bars ]]--

--[[
    @description    "Creates a bar with the param values"
	
	
	@param                 sX,    number
	@param                 fX,    number
	@param                  y,    number
	@param    currentProgress,    number
	@param             maxLen,    number
	@param                box,   boolean
	
	@return          table
--]]
function initBar(sX, fX, y, currentProgress, maxLen, box)
    local bar = {}
	bar.sX = math.ceil(sX)
	bar.fX = math.ceil(fX)
	bar.y  = math.ceil(y)
	bar.currentProgress = currentProgress or 0
	bar.maxLen = maxLen
	bar.percent = (currentProgress/maxLen) * 100
	bar.barWidth = 0
    for i = sX,fX do
        bar.barWidth = bar.barWidth + 1
    end
    bar.box = box or false
	return bar
end

--[[
    @description    "Draws the bar"
	
	
	@param               bar,    table
	@param     artProperties,    table
	
	@return         nil
--]]
function drawBar(bar,artProperties)

    local boxColor
	local barColor
	local barBackgroundColor
    if artProperties then
        boxColor = artProperties.boxColor or colors.lightGray
	    barColor = artProperties.barColor or colors.lime
	    barBackgroundColor = artProperties.barBackgroundColor or colors.gray
	else
	    boxColor = colors.lightGray
		barColor = colors.lime
		barBackgroundColor = colors.gray
	end
	
	if bar.box then
        gui.drawBox(bar.sX - 1,bar.fX + 1,bar.y - 1,bar.y + 1,boxColor)
	end
	for i = 1, bar.barWidth do
		term.setCursorPos( ( bar.sX - 1 ) + i, bar.y)
		local char = ' '
		if i < (( bar.currentProgress / bar.maxLen ) * bar.barWidth + 1) then
				term.setBackgroundColor( barColor )
		else
				term.setBackgroundColor( barBackgroundColor )
		end
		write( char )
	end
end
	

--[[
    @description    "Updates the 'bar table' with a new value for the current progress and draws it"
	
	
	@param          newValue,    number
	@param     artProperties,    table
	
	@return         nil
--]]
function updateBar(bar,newValue,artProperties)
    bar.currentProgress = newValue
	bar.percent = (bar.currentProgress/bar.maxLen) * 100
	drawBar(bar,artProperties)
end








--[[ Menus ]]--

--[[ 
 @description    "Loading the theme file for a menu"


 @param          destination,    string 
 
 @return         table
--]]
function loadTheme(destination)

    local names = {"activeTextCol", "bColor", "defaultTextCol", "headerTextCol", "headerBackCol", "activeBackCol",}
	local colorTable = {}
	
   --  Loading the theme file and converting it into a color table.
    local menuTheme = convertFileToTable(destination)

	  --  Now we get the index names for the table
	    for i, v in ipairs(menuTheme) do
		     for k = 1,#names do
			     if string.find(v,names[k]) then name = names[k] break end
		     end
            colorTable[name] = colors[v:match("%=% *(%w+)")]
        end
	        return colorTable
			
end


--[[
    @description    "Handles menu tables and events"


	@param           tMenu,    table
	@param        language,    string
	@param   artProperties,    table
	
    @return            nil
--]]
function handleMenu(tMenu,artProperties)

    local menu = tMenu.defMenu --# The default/starting menu you will enter the first time
	local language = tMenu.defLanguage
    local visitedMenus = {}
    local runAnim = false
    local mNum = 1

	
    while true do
       language = tMenu.defLanguage
	      --# Adding the positions of the options in the menu so we can check where they are on the screen when clicking
          for i = 1, #tMenu[language][menu] do
	          tMenu[language][menu][i].sX = math.ceil(w/2 - (#tMenu[language][menu][i].name/2 + 1))
		      tMenu[language][menu][i].fX = math.floor(w/2 + (#tMenu[language][menu][i].name/2 + 1))
		      tMenu[language][menu][i].y = 5 + i
	      end
	
          --# We start with drawing the menu, Then we wait for the events
          if artProperties == nil then 
	          error("Failed, Theme was corrupt/empty",2)
	      end
 
 
 
--# Local variables that are used for drawing the menu, They are the ones that set text color etc.
          local mBackCol        = artProperties.bColor
	      local mDefaultTextCol = artProperties.defaultTextCol
	      local mActiveTextCol  = artProperties.activeTextCol
	      local mActiveBackCol  = artProperties.activeBackCol
	      local headerBackCol   = artProperties.headerBackCol
	      local headerTextCol   = artProperties.headerTextCol
	
  
--# Actually start drawing the menu
local function drawMenu()
    term.setBackgroundColor(mBackCol)
    clear()
    drawBox(1,w,1,3,headerBackCol)
    centerPrint(2,headerTextCol,headerBackCol,tMenu[language][menu].title)

    for i = 1,#tMenu[language][menu] do

        if mNum == i then
            centerPrint(5 + i,mActiveTextCol,mActiveBackCol," "..tMenu[language][menu][i].name.." ")
        else
            centerPrint(5 + i,mDefaultTextCol,mBackCol,tMenu[language][menu][i].name)
        end
    end
end

	        drawMenu()
			  

--# An menu animation function, Doesn't return anything
local function mAnimation(text,y,boolean)
    if boolean then
	    local sX = w/2 - #text/2
	    local fX = w/2 + #text/2
	    
		for i = w/2 - #text/2, w/2 do
		    term.setBackgroundColor(mActiveBackCol)
            drawAt(sX,y," ")
			drawAt(fX,y," ")
						   
	        term.setBackgroundColor(mBackCol)
            drawAt(sX - 1,y," ")
			drawAt(fX + 1,y," ")
						   
			sX = sX + 1
			fX = fX - 1
			sleep(0.05)
		end
	else
		local sX = w/2
	    local fX = w/2
				   
		local str = ""
		for i = 1,#text + 2 do
		    str = str.." "
		end
			centerPrint(y,nil,mBackColor,str)
					
	    for i = w/2, w/2 + #text/2 do
		    term.setBackgroundColor(mActiveBackCol)
            drawAt(sX,y," ")
			drawAt(fX,y," ")
						   
			term.setBackgroundColor(mBackCol)
            drawAt(sX - 1,y," ")
			drawAt(fX + 1,y," ")
						   
			sX = sX - 1
			fX = fX + 1
			sleep(0.05)
	    end
			       
    end			
end



		   
if runAnim then
	mAnimation(tMenu[language][menu][mNum].name,tMenu[language][menu][mNum].y,false)
	runAnim = false
	drawMenu()
end

 --# Here we wait for the events and handle them
  local evt, p1, mX, mY = os.pullEvent()
        if evt == "key" then
		
            if p1 == 200 then
	            mNum = mNum  - 1  if mNum < 1 then mNum = 1 end
	
	        elseif p1 == 208 then
	            mNum = mNum + 1
	                if mNum > #tMenu[language][menu] then mNum = #tMenu[language][menu] end
	
	        elseif p1 == 28 then
					if tMenu[language][menu][mNum].destination ~= nil then
					     mAnimation(tMenu[language][menu][mNum].name,tMenu[language][menu][mNum].y,true)
	                end  
	            
				if tMenu[language][menu][mNum].destination ~= nil and tMenu[language][menu][mNum].destination ~= "_back" and tMenu[language][menu][mNum].destination ~= "_exit" and tMenu[language][menu][mNum].destination ~= "_function" then 
	                runAnim = true
					table.insert(visitedMenus,menu)
	                menu = tMenu[language][menu][mNum].destination
	                mNum = 1
	 
	 
	            elseif tMenu[language][menu][mNum].destination == "_back" then --# Going back to the previous menu that you were in
	                mNum = 1
	                menu = visitedMenus[#visitedMenus]
							    if #visitedMenus ~= 0 then
                                    runAnim = true
                                end	
	                table.remove(visitedMenus,#visitedMenus)
	 
	            elseif tMenu[language][menu][mNum].destination == "_function" then
	                functionName = tMenu[language][menu][mNum]["tFunction"].name
	  
	                if tMenu[language][menu][mNum]["tFunction"]["args"] ~= nil then
	                    args = tMenu[language][menu][mNum]["tFunction"]["args"]
	                else
	                    args = ""
	                end
	  
	  
	                if #args ~= 0 then
	                    functionName(unpack(args)) --# Calling the function from the table with arguments
	                else
					    functionName()
				    end
	 
	            elseif tMenu[language][menu][mNum].destination == "_exit" then --# Exiting the program/game if the destination in the table is "_exit"
	                term.setTextColor(colors.white) term.setBackgroundColor(colors.black)
	                clear()
	                error()
	            end
	 
            end
			
			
			
		elseif evt == "mouse_click" then
		
		    for i = 1, #tMenu[language][menu] do
		        if mX >= tMenu[language][menu][i].sX and mX <= tMenu[language][menu][i].fX and mY == tMenu[language][menu][i].y then
				    if mNum ~= i then
					    mNum = i
					    break
					else
					
					if tMenu[language][menu][mNum].destination ~= nil then
					     mAnimation(tMenu[language][menu][mNum].name,tMenu[language][menu][mNum].y,true)
	                end    
						if tMenu[language][menu][mNum].destination ~= nil and tMenu[language][menu][mNum].destination ~= "_back" and tMenu[language][menu][mNum].destination ~= "_exit" and tMenu[language][menu][mNum].destination ~= "_function" then 
	                        runAnim = true
							table.insert(visitedMenus,menu)
	                        menu = tMenu[language][menu][mNum].destination
	                        mNum = 1
							break
	 
	 
	                    elseif tMenu[language][menu][mNum].destination == "_back" then --# Going back to the previous menu that you were in
	                        mNum = 1
	                        menu = visitedMenus[#visitedMenus]
							    if #visitedMenus ~= 0 then
                                    runAnim = true
                                end	
	                        table.remove(visitedMenus,#visitedMenus)								
							break
	 
	                    elseif tMenu[language][menu][mNum].destination == "_function" then
	                        functionName = tMenu[language][menu][mNum]["tFunction"].name
	  
	                        if tMenu[language][menu][mNum]["tFunction"]["args"] ~= nil then
	                            args = tMenu[language][menu][mNum]["tFunction"]["args"]
	  
	                        else
	                            args = ""
	                        end
	                          
							  if #args ~= 0 then
	                              functionName(unpack(args)) --# Calling the function from the table with arguments
	                          else
							      functionName()
							  end
							  
	                    elseif tMenu[language][menu][mNum].destination == "_exit" then --# Exiting the program/game if the destionation in the table is "_exit"
	                        term.setTextColor(colors.white) term.setBackgroundColor(colors.black)
	                        clear()
	                        error()
	                    end
					    
					  
					end
				end
			end
			
        end
    end
  
end








--[[ Misc ]]--

--[[
    @description    "A modified reading function"
	
	
	@param          properties,    table
	
	@return         string
--]]
 function mRead(properties)

--[[
    --# Properties
 
        * textLength: The maxium textlength
        * allowedChars: The allowed chars to type, This will block all except them, Example: cRead({textLength = 4, allowedChars = "1234567890"}) will only allow numbers from 0-9
        * blockedChars: The chars that is blocked from being typed.
	    * replaceChar: replaces the char like read("*") --> replaceChar = "*"
        * exitOnKey: Exits on the desired key and returns nil
]]--
    
  --# Initializing variables, functions etc.
	term.setCursorBlink(true)
    local curX, curY = term.getCursorPos()
    local text = ""

local function reDraw()
    if properties.centeredText then
	   local str = ""
	   for i = 1,#text + 2 do
	       str = str.." "
	   end
	   centerPrint(curY,nil,nil,str)
	else
        for i = 1,#text + 1 do
            drawAt(curX - 1 + i,curY," ")
        end
	end
end


-- Locals
    local textLength
    local repChar
    local charTable
	local bChars
    local exitKey

 
    while true do
	  --# Checking the table properties
        if properties ~= nil then
            
			if properties.replaceChar ~= nil then
                repChar = string.sub(properties.replaceChar,1,1)
            end
            if properties.textLength ~= nil then
                textLength = properties.textLength
            end
            if properties.allowedChars ~= nil then
                charTable = {} 
			        for i = 1,#properties.allowedChars do 
				        table.insert(charTable,string.sub(properties.allowedChars,i,i)) 
			        end
            end
		    if properties.blockedChars ~= nil then
		        bChars = {}
                    for i = 1, #properties.blockedChars do
                        table.insert(bChars,string.sub(properties.blockedChars,i,i))
                    end
            end				   
            if properties.exitOnKey ~= nil then
                exitKey = properties.exitOnKey
            end
        
		end

		
		
local function charCheck(str,string)
    if properties.blockedChars ~= nil then
        for i = 1,#bChars do
            str = string.gsub(str,bChars[i],"")
        end
    end	

    if properties.allowedChars ~= nil then
        if #charTable ~= 0 then local add = false 

     		for i = 1,#charTable do 
                if str == charTable[i] then add = true break end 
            end
			
          if add then string = string..str end
          end
    else
          string = string..str
    end
          return string
end



 --# Drawing the text to the screen
  reDraw()
      if repChar == nil then
	      if properties.centeredText then
		      centerPrint(curY,nil,nil,text)
		  else
              drawAt(curX,curY,text)
		  end
      else
          local str = ""
          for i = 1,#text do
              str = str..repChar
          end
		  
		  if properties.centeredText then
              centerPrint(curY,nil,nil,str)
		  else		  
              drawAt(curX,curY,str)
		  end
      end


	  
	  
local evt, p1 = os.pullEvent()
    if evt == "char" then 
        if textLength ~= nil then 
            if #text < textLength then text = charCheck(p1,text) end
        else
            text = charCheck(p1,text)
        end

    elseif evt == "key" then 
        if exitKey ~= nil then if p1 == exitKey then term.setCursorBlink(false) return nil end end
            if p1 == 14 then text = string.sub(text,1,#text - 1)
    
            elseif p1 == 57 then text = text..""
    
            elseif p1 == 28 then term.setCursorBlink(false) return text
	
            end
    end
    end
end


--[[
    @description    "Loads apis from a folder, With GUI or not"
	
	
	@param             path,    string
	@param          barMode,    boolean
	@param                y,    number
	@param           bColor,    number
	@param           tColor,    number
	@param    artProperties,    table
	
	@return         nil
]]--
function loadAPIs(path, barMode, y, tColor, bColor, artProperties)
    local files = {}
	for _, file in ipairs(fs.list(path)) do
	    table.insert(files, path .. file)
	end
	if barMode then
	    local bCol = bColor or colors.black
		local tCol = tColor or colors.white
	    local bar = initBar(2, w - 1, y, 0, #files)
		if y < 4 then
		    y = 4
		end
		if y > h - 1 then
		    y = h - 1
		end
		
	    for i = 1,#files do
		    clear(bCol)
		    os.loadAPI(files[i])
			drawBox(bar.sX, bar.fX, bar.y - 3, bar.y + 1,artProperties.boxColor)
			updateBar(bar, i, artProperties)
			local s, f = string.find(files[i], path)
			local file = string.sub(files[i],f + 1,#files[i])
			centerPrint(bar.y - 3,tCol, artProperties.boxColor,"Loading APIs")
			centerPrint(bar.y - 1,tCol, artProperties.boxColor,i .. "/" .. #files)
			centerPrint(bar.y + 1,tCol, artProperties.boxColor,"Loading API: " .. file)
			sleep(.2) -- Just so you can see when it's loading
		end
	
	else
	    for i = 1,#files do
		    os.loadAPI(files[i])
		end
	end
end
