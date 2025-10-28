-- {"id":10002,"ver":"1.0.0","libVer":"1.0.0","author":"Imugiii","repo":"https://github.com/Imugiii/shosetsu-extension-fr"}

--- J-Garden - Traductions de Light Novels japonais
local BASE_URL = "https://j-garden.fr"

local settings = {
    name = "J-Garden",
    baseURL = BASE_URL,
    imageURL = "https://j-garden.fr/wp-content/uploads/2021/01/cropped-logo-jg-32x32.png",
    id = 10002,
    lang = "fr",
    isSearchIncrementing = true,
    chapterType = ChapterType.HTML
}

local function getSearch(data)
    local query = data[QUERY] or ""
    local url = BASE_URL .. "/?s=" .. query:gsub(" ", "+")
    
    local doc = GETDocument(url)
    local novels = {}
    
    local items = doc:select("article.post")
    
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        local linkElement = item:selectFirst(".entry-title a")
        local imageElement = item:selectFirst(".entry-image img")
        
        if linkElement then
            local novel = Novel()
            novel:setTitle(linkElement:text())
            novel:setLink(linkElement:attr("href"))
            
            if imageElement then
                novel:setImageURL(imageElement:attr("src"))
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
    
    local descElement = doc:selectFirst(".entry-content")
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
        
        if text:find("Chapitre") or text:find("Volume") or text:find("Prologue") or text:find("Épilogue") then
            local chapter = NovelChapter()
            chapter:setTitle(text)
            chapter:setLink(link:attr("href"))
            chapter:setOrder(i)
            chapters[#chapters + 1] = chapter
        end
    end
    
    return chapters
end

local function getPassageData(chapterURL)
    local doc = GETDocument(chapterURL)
    local contentElement = doc:selectFirst(".entry-content")
    
    if contentElement then
        return contentElement:html()
    end
    
    return ""
end

return {
    id = settings.id,
    name = settings.name,
    baseURL = settings.baseURL,
    imageURL = settings.imageURL,
    lang = settings.lang,
    isSearchIncrementing = settings.isSearchIncrementing,
    chapterType = settings.chapterType,
    getSearch = getSearch,
    parseNovel = parseNovel,
    getChapters = getChapters,
    getPassageData = getPassageData
}
