import os
import re
import httpx
from typing import Dict, List, Optional
from dataclasses import dataclass

@dataclass
class YouTubeVideoInfo:
    title: str
    description: str
    thumbnail: str
    duration: int
    channel_title: str
    view_count: int
    like_count: int

class YouTubeService:
    def __init__(self):
        # 这里可以配置YouTube Data API密钥
        self.api_key = os.getenv('YOUTUBE_API_KEY', '')
        self.base_url = 'https://www.googleapis.com/youtube/v3'
    
    async def get_video_info(self, video_id: str) -> YouTubeVideoInfo:
        """获取YouTube视频信息"""
        if not self.api_key:
            # 如果没有API密钥，返回模拟数据
            return self._get_mock_video_info(video_id)
        
        try:
            async with httpx.AsyncClient() as client:
                url = f"{self.base_url}/videos"
                params = {
                    'part': 'snippet,statistics,contentDetails',
                    'id': video_id,
                    'key': self.api_key
                }
                
                response = await client.get(url, params=params)
                data = response.json()
                
                if 'items' not in data or not data['items']:
                    raise ValueError(f"视频 {video_id} 不存在")
                
                item = data['items'][0]
                snippet = item['snippet']
                statistics = item['statistics']
                content_details = item['contentDetails']
                
                # 解析时长
                duration = self._parse_duration(content_details['duration'])
                
                return YouTubeVideoInfo(
                    title=snippet['title'],
                    description=snippet['description'],
                    thumbnail=snippet['thumbnails']['high']['url'],
                    duration=duration,
                    channel_title=snippet['channelTitle'],
                    view_count=int(statistics.get('viewCount', 0)),
                    like_count=int(statistics.get('likeCount', 0))
                )
                
        except Exception as e:
            print(f"获取YouTube视频信息失败: {e}")
            return self._get_mock_video_info(video_id)
    
    def _get_mock_video_info(self, video_id: str) -> YouTubeVideoInfo:
        """返回模拟视频信息（用于演示）"""
        return YouTubeVideoInfo(
            title=f"示例视频 {video_id}",
            description=f"这是一个示例视频的描述，视频ID为 {video_id}",
            thumbnail=f"https://img.youtube.com/vi/{video_id}/maxresdefault.jpg",
            duration=3600,  # 1小时
            channel_title="示例频道",
            view_count=10000,
            like_count=500
        )
    
    def _parse_duration(self, duration: str) -> int:
        """解析ISO 8601格式的时长"""
        # 格式: PT1H2M3S
        pattern = r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?'
        match = re.match(pattern, duration)
        
        if not match:
            return 0
        
        hours = int(match.group(1) or 0)
        minutes = int(match.group(2) or 0)
        seconds = int(match.group(3) or 0)
        
        return hours * 3600 + minutes * 60 + seconds
    
    async def get_video_transcript(self, video_id: str) -> Optional[str]:
        """获取视频字幕（需要YouTube Data API v3）"""
        # 这里可以实现获取视频字幕的功能
        # 由于YouTube API限制，可能需要使用第三方服务
        return None
    
    async def search_videos(self, query: str, max_results: int = 10) -> List[Dict]:
        """搜索YouTube视频"""
        if not self.api_key:
            return []
        
        try:
            async with httpx.AsyncClient() as client:
                url = f"{self.base_url}/search"
                params = {
                    'part': 'snippet',
                    'q': query,
                    'type': 'video',
                    'maxResults': max_results,
                    'key': self.api_key
                }
                
                response = await client.get(url, params=params)
                data = response.json()
                
                videos = []
                for item in data.get('items', []):
                    videos.append({
                        'video_id': item['id']['videoId'],
                        'title': item['snippet']['title'],
                        'description': item['snippet']['description'],
                        'thumbnail': item['snippet']['thumbnails']['high']['url'],
                        'channel_title': item['snippet']['channelTitle']
                    })
                
                return videos
                
        except Exception as e:
            print(f"搜索YouTube视频失败: {e}")
            return []

# 全局实例
youtube_service = YouTubeService()
