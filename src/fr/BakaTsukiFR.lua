-- {"id":10003,"ver":"1.0.0","libVer":"1.0.0","author":"Imugiii","repo":"https://github.com/Imugiii/shosetsu-extension-fr"}

--- Baka-Tsuki FR - Light Novels traduits en français
local BASE_URL = "https://www.baka-tsuki.org"

local settings = {
    name = "Baka-Tsuki FR",
    baseURL = BASE_URL,
    imageURL = "https://www.baka-tsuki.org/project/logo.png",
    id = 10003,
    lang = "fr",
    isSearchIncrementing = true,
    chapterType = ChapterType.HTML
}

local function listings(data)
    local url = BASE_URL .. "/project/index.php?title=Catégorie:Français"
    
    local doc = GETDocument(url)
    local novels = {}
    
    local items = doc:select("#mw-pages .mw-content-ltr li a")
    
    for i = 0, items:size() - 1 do
        local link = items:get(i)
        local title = link:text()
        
        local novel = Novel()
        novel:setTitle(title)
        local href = link:attr("href")
        if href:sub(1, 1) == "/" then
            novel:setLink(BASE_URL .. href)
        else
            novel:setLink(BASE_URL .. "/project/index.php" .. href)
        end
        novels[#novels + 1] = novel
    end
    
    return novels
end

local function getSearch(data)
    local query = data[QUERY] or ""
    local url = BASE_URL .. "/project/index.php?title=Catégorie:Français"
    
    local doc = GETDocument(url)
    local novels = {}
    
    local items = doc:select("#mw-pages .mw-content-ltr li a")
    
    for i = 0, items:size() - 1 do
        local link = items:get(i)
        local title = link:text()
        
        if query == "" or title:lower():find(query:lower()) then
            local novel = Novel()
            novel:setTitle(title)
            local href = link:attr("href")
            if href:sub(1, 1) == "/" then
                novel:setLink(BASE_URL .. href)
            else
                novel:setLink(BASE_URL .. "/project/index.php" .. href)
            end
            novels[#novels + 1] = novel
        end
    end
    
    return novels
end

local function parseNovel(url)
    local doc = GETDocument(url)
    local novel = NovelInfo()
    
    local titleElement = doc:selectFirst("#firstHeading")
    if titleElement then
        local title = titleElement:text():gsub(" ~ Français", "")
        novel:setTitle(title)
    end
    
    local imageElement = doc:selectFirst(".infobox img")
    if imageElement then
        local imgSrc = imageElement:attr("src")
        if imgSrc:sub(1, 2) == "//" then
            novel:setImageURL("https:" .. imgSrc)
        elseif imgSrc:sub(1, 1) == "/" then
            novel:setImageURL("https:" .. imgSrc)
        elseif not imgSrc:find("^https?://") then
            novel:setImageURL(BASE_URL .. imgSrc)
        else
            novel:setImageURL(imgSrc)
        end
    end
    
    novel:setStatus(NovelStatus.PUBLISHING)
    return novel
end

local function getChapters(url)
    local doc = GETDocument(url)
    local chapters = {}
    
    local volumeElements = doc:select("h2, h3")
    
    for i = 0, volumeElements:size() - 1 do
        local heading = volumeElements:get(i)
        local nextSibling = heading:nextElementSibling()
        
        if nextSibling and nextSibling:tagName() == "ul" then
            local links = nextSibling:select("li a")
            
            for j = 0, links:size() - 1 do
                local link = links:get(j)
                local chapter = NovelChapter()
                chapter:setTitle(link:text())
                local href = link:attr("href")
                if href:sub(1, 1) == "/" then
                    chapter:setLink(BASE_URL .. href)
                else
                    chapter:setLink(BASE_URL .. "/project/index.php" .. href)
                end
                chapter:setOrder(#chapters)
                chapters[#chapters + 1] = chapter
            end
        end
    end
    
    return chapters
end

local function getPassage(chapterURL)
    local doc = GETDocument(chapterURL)
    local contentElement = doc:selectFirst("#mw-content-text")
    
    if contentElement then
        local navElements = contentElement:select(".toc, .navbox")
        for i = 0, navElements:size() - 1 do
            navElements:get(i):remove()
        end
        
        return contentElement:html()
    end
    
    return ""
end

local function getPassageData(chapterURL)
    return getPassage(chapterURL)
end

return {
    id = settings.id,
    name = settings.name,
    baseURL = settings.baseURL,
    imageURL = settings.imageURL,
    lang = settings.lang,
    isSearchIncrementing = settings.isSearchIncrementing,
    chapterType = settings.chapterType,
    listings = {listings},
    getSearch = getSearch,
    parseNovel = parseNovel,
    getChapters = getChapters,
    getPassage = getPassage,
    getPassageData = getPassageData
}
