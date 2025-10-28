-- {"id":10004,"ver":"1.0.0","libVer":"1.0.0","author":"Imugiii","repo":"https://github.com/Imugiii/shosetsu-extension-fr"}

--- Novel de Glace - Light Novels français (Isekai, Seinen)
local BASE_URL = "https://noveldeglace.com"

local settings = {
    name = "Novel de Glace",
    baseURL = BASE_URL,
    imageURL = "https://noveldeglace.com/favicon.ico",
    id = 10004,
    lang = "fr",
    isSearchIncrementing = true,
    chapterType = ChapterType.HTML
}

local function listings(data)
    local page = data[PAGE_INDEX] or 1
    local url = BASE_URL
    if page > 1 then
        url = BASE_URL .. "/page/" .. page
    end
    
    local doc = GETDocument(url)
    local novels = {}
    
    local items = doc:select("article.post")
    
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        local linkElement = item:selectFirst(".entry-title a")
        local imageElement = item:selectFirst(".post-thumbnail img")
        
        if linkElement then
            local novel = Novel()
            novel:setTitle(linkElement:text())
            novel:setLink(linkElement:attr("href"))
            
            if imageElement then
                local imgUrl = imageElement:attr("src")
                if imgUrl == "" then
                    imgUrl = imageElement:attr("data-src")
                end
                novel:setImageURL(imgUrl)
            end
            
            novels[#novels + 1] = novel
        end
    end
    
    return novels
end

local function getSearch(data)
    local query = data[QUERY] or ""
    local url = BASE_URL .. "/?s=" .. query:gsub(" ", "+")
    
    local doc = GETDocument(url)
    local novels = {}
    
    local items = doc:select("article.post")
    
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        local linkElement = item:selectFirst(".entry-title a")
        local imageElement = item:selectFirst(".post-thumbnail img")
        
        if linkElement then
            local novel = Novel()
            novel:setTitle(linkElement:text())
            novel:setLink(linkElement:attr("href"))
            
            if imageElement then
                local imgUrl = imageElement:attr("src")
                if imgUrl == "" then
                    imgUrl = imageElement:attr("data-src")
                end
                novel:setImageURL(imgUrl)
            end
            
            novels[#novels + 1] = novel
        end
    end
    
    return novels
end

local function parseNovel(url)
    local doc = GETDocument(url)
    local novel = NovelInfo()
    
    local titleElement = doc:selectFirst("h1.entry-title")
    if titleElement then
        novel:setTitle(titleElement:text())
    end
    
    local imageElement = doc:selectFirst(".entry-content img")
    if imageElement then
        novel:setImageURL(imageElement:attr("src"))
    end
    
    local descElement = doc:selectFirst(".entry-content p")
    if descElement then
        novel:setDescription(descElement:text())
    end
    
    novel:setStatus(NovelStatus.PUBLISHING)
    return novel
end

local function getChapters(url)
    local doc = GETDocument(url)
    local chapters = {}
    
    local linkElements = doc:select(".entry-content a")
    
    for i = 0, linkElements:size() - 1 do
        local link = linkElements:get(i)
        local text = link:text()
        
        if text:find("Chapitre") or text:find("Volume") or text:find("Prologue") or text:find("Tome") then
            local chapter = NovelChapter()
            chapter:setTitle(text)
            chapter:setLink(link:attr("href"))
            chapter:setOrder(i)
            chapters[#chapters + 1] = chapter
        end
    end
    
    return chapters
end

local function getPassage(chapterURL)
    local doc = GETDocument(chapterURL)
    local contentElement = doc:selectFirst(".entry-content")
    
    if contentElement then
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
    listings = listings,
    getSearch = getSearch,
    parseNovel = parseNovel,
    getChapters = getChapters,
    getPassage = getPassage,
    getPassageData = getPassageData
}
