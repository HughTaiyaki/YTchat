import asyncio
import json
import httpx
import re
import os
import mysql.connector
from mysql.connector import Error
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass
import uvicorn
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from youtube_service import youtube_service, YouTubeVideoInfo

# 使用你现有的API配置
qianfan_headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer bce-v3/ALTAK-Lz8A6o7S7rDGh4q6QEYWr/86041c57d0cb7fc5f1d496d4e31c4dc8a03de20f",
}

qianfan_chat_url = "https://qianfan.baidubce.com/v2/chat/completions"

# MySQL数据库配置
DB_CONFIG = {
    'host': 'localhost',
    'port': 3306,
    'user': 'root',
    'password': 'xxxxxxx',
    'database': 'ytchat',
    'charset': 'utf8mb4'
}

@dataclass
class VideoInfo:
    title: str
    description: str
    thumbnail: str
    duration: int

class ChatRequest(BaseModel):
    question: str

class ChatResponse(BaseModel):
    answer: str
    video_id: Optional[int] = None
    youtube_id: Optional[str] = None
    start_time: Optional[int] = None
    end_time: Optional[int] = None

app = FastAPI()

def get_db_connection():
    """获取数据库连接"""
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        return connection
    except Error as e:
        print(f"数据库连接错误: {e}")
        return None

def get_all_videos():
    """获取所有视频信息"""
    connection = get_db_connection()
    if not connection:
        return []
    
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.execute("SELECT * FROM videos")
        videos = cursor.fetchall()
        return videos
    except Error as e:
        print(f"查询视频错误: {e}")
        return []
    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()

def get_video_segments(video_id: int):
    """获取指定视频的所有片段"""
    connection = get_db_connection()
    if not connection:
        return []
    
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.execute("SELECT * FROM video_segments WHERE video_id = %s ORDER BY start_time", (video_id,))
        segments = cursor.fetchall()
        return segments
    except Error as e:
        print(f"查询视频片段错误: {e}")
        return []
    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()

def search_video_content(query: str):
    """搜索视频内容"""
    connection = get_db_connection()
    if not connection:
        return []
    
    try:
        cursor = connection.cursor(dictionary=True)
        # 搜索视频标题、描述和片段内容
        search_query = """
        SELECT DISTINCT v.id, v.title, v.description, v.you_tube_id, v.duration,
               s.id as segment_id, s.start_time, s.end_time, s.content, s.summary
        FROM videos v
        LEFT JOIN video_segments s ON v.id = s.video_id
        WHERE v.title LIKE %s OR v.description LIKE %s 
           OR s.content LIKE %s OR s.summary LIKE %s
        ORDER BY v.id, s.start_time
        """
        search_term = f"%{query}%"
        cursor.execute(search_query, (search_term, search_term, search_term, search_term))
        results = cursor.fetchall()
        return results
    except Error as e:
        print(f"搜索视频内容错误: {e}")
        return []
    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()

# 模拟数据库连接（实际项目中应该连接真实数据库）
videos_db = {}
segments_db = {}

@app.get("/")
async def root():
    return {"message": "YouTube Chat Python Service"}

@app.get("/video/{video_id}")
async def get_video_info(video_id: str):
    """获取视频信息"""
    try:
        # 调用YouTube服务获取真实视频信息
        youtube_info = await youtube_service.get_video_info(video_id)
        
        video_info = VideoInfo(
            title=youtube_info.title,
            description=youtube_info.description,
            thumbnail=youtube_info.thumbnail,
            duration=youtube_info.duration
        )
        return video_info
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/video/{video_id}/analyze")
async def analyze_video(video_id: str):
    """分析视频内容并生成片段"""
    try:
        # 这里应该调用YouTube API获取视频内容
        # 然后使用AI分析生成片段
        segments = await generate_video_segments(video_id)
        return {"segments": segments}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    """处理聊天请求"""
    try:
        response = await process_question(request.question)
        return response
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

async def generate_video_segments(video_id: str) -> List[Dict]:
    """生成视频片段"""
    try:
        # 获取视频信息
        youtube_info = await youtube_service.get_video_info(video_id)
        total_duration = youtube_info.duration
        
        # 使用AI分析视频内容并生成片段
        segments = await analyze_video_with_ai(video_id, youtube_info)
        
        return segments
    except Exception as e:
        print(f"生成视频片段失败: {e}")
        # 返回默认片段
        return await generate_default_segments(video_id)

async def analyze_video_with_ai(video_id: str, video_info: YouTubeVideoInfo) -> List[Dict]:
    """使用AI分析视频内容"""
    # 构建AI提示词
    messages = [{
        "role": "system",
        "content": f"""你是一个专业的视频内容分析助手。请分析以下YouTube视频，将其分成有意义的时间片段。

视频信息：
- 标题: {video_info.title}
- 描述: {video_info.description[:500]}...
- 时长: {video_info.duration}秒

请将视频分成5-10个有意义的片段，每个片段包含：
1. 开始时间（秒）
2. 结束时间（秒）
3. 片段内容描述
4. 片段摘要

输出格式为JSON数组：
[
  {{
    "start_time": 0,
    "end_time": 300,
    "content": "片段内容描述",
    "summary": "片段详细摘要"
  }},
  ...
]"""
    }]
    
    data = {
        "model": "ernie-3.5-8k-preview",
        "messages": messages,
    }
    
    async with httpx.AsyncClient() as client:
        try:
            response = await client.post(
                url=qianfan_chat_url, 
                json=data, 
                headers=qianfan_headers, 
                timeout=60
            )
            result = response.json()
            
            if "error" in result:
                print(f"AI分析失败: {result.get('error', {}).get('message', str(result))}")
                return await generate_default_segments(video_id)
            
            content = result.get("choices")[0].get("message", {}).get("content")
            if not content:
                return await generate_default_segments(video_id)
            
            # 解析JSON响应
            try:
                json_start = content.find('[')
                json_end = content.rfind(']') + 1
                if json_start >= 0 and json_end > json_start:
                    json_str = content[json_start:json_end]
                    segments = json.loads(json_str)
                    return segments
            except:
                pass
            
            return await generate_default_segments(video_id)
            
        except Exception as e:
            print(f"AI分析出错: {e}")
            return await generate_default_segments(video_id)

async def generate_default_segments(video_id: str) -> List[Dict]:
    """生成默认片段（当AI分析失败时使用）"""
    segments = []
    
    # 获取视频信息以确定时长
    try:
        youtube_info = await youtube_service.get_video_info(video_id)
        total_duration = youtube_info.duration
    except:
        total_duration = 3600  # 默认1小时
    
    # 生成5个等长片段
    segment_duration = total_duration // 5
    for i in range(5):
        start_time = i * segment_duration
        end_time = min((i + 1) * segment_duration, total_duration)
        
        segment = {
            "start_time": start_time,
            "end_time": end_time,
            "content": f"视频片段 {i+1} - 第{start_time//60}分钟到第{end_time//60}分钟",
            "summary": f"这是视频的第{i+1}个片段，包含了视频的重要内容和关键信息。"
        }
        segments.append(segment)
    
    return segments

async def process_question(question: str) -> ChatResponse:
    """处理用户问题"""
    
    # 首先搜索相关的视频内容
    search_results = search_video_content(question)
    
    # 构建上下文信息
    context_info = ""
    if search_results:
        context_info = "以下是相关的视频内容：\n\n"
        for result in search_results[:5]:  # 限制最多5个结果
            context_info += f"视频ID: {result['id']}\n"
            context_info += f"标题: {result['title']}\n"
            context_info += f"YouTube ID: {result['you_tube_id']}\n"
            if result['segment_id']:
                context_info += f"片段时间: {result['start_time']}-{result['end_time']}秒\n"
                context_info += f"片段内容: {result['content']}\n"
                context_info += f"片段摘要: {result['summary']}\n"
            else:
                context_info += f"视频描述: {result['description']}\n"
            context_info += "\n---\n\n"
    else:
        # 如果没有搜索结果，获取所有视频列表
        all_videos = get_all_videos()
        if all_videos:
            context_info = "当前视频库中的视频：\n\n"
            for video in all_videos:
                context_info += f"视频ID: {video['id']}\n"
                context_info += f"标题: {video['title']}\n"
                context_info += f"YouTube ID: {video['you_tube_id']}\n"
                context_info += f"描述: {video['description'][:200]}...\n"
                context_info += "\n---\n\n"
    
    # 构建AI提示词
    system_prompt = f"""你是一个专业的视频内容问答助手。基于提供的视频库内容回答用户问题。

{context_info}

回答规则：
1. 只基于上述提供的视频内容回答问题
2. 如果问题涉及特定视频片段，请提供准确的视频ID、开始时间和结束时间
3. 如果问题询问视频列表，请列出所有可用的视频
4. 如果找不到相关内容，请明确说明

回答格式：
- 如果涉及具体视频片段，返回JSON格式：
{{
    "answer": "详细回答内容",
    "video_id": 数据库中的视频ID（数字）,
    "start_time": 开始时间（秒）,
    "end_time": 结束时间（秒）
}}
- 如果是一般性回答，返回：
{{
    "answer": "回答内容"
}}

注意：video_id必须是数据库中的视频ID（数字），不是YouTube视频ID。"""

    messages = [{
        "role": "system",
        "content": system_prompt
    }, {
        "role": "user",
        "content": question
    }]
    
    data = {
        "model": "ernie-3.5-8k-preview",
        "messages": messages,
    }
    
    async with httpx.AsyncClient() as client:
        try:
            response = await client.post(
                url=qianfan_chat_url, 
                json=data, 
                headers=qianfan_headers, 
                timeout=50
            )
            result = response.json()
            
            if "error" in result:
                return ChatResponse(
                    answer=f"AI服务错误: {result.get('error', {}).get('message', str(result))}"
                )
            
            content = result.get("choices")[0].get("message", {}).get("content")
            if not content:
                return ChatResponse(answer="AI服务响应格式错误")
            
            # 尝试解析JSON响应
            try:
                json_start = content.find('{')
                json_end = content.rfind('}') + 1
                if json_start >= 0 and json_end > json_start:
                    json_str = content[json_start:json_end]
                    response_data = json.loads(json_str)
                    
                    # 如果有video_id，获取对应的YouTube ID
                    youtube_id = None
                    if response_data.get("video_id"):
                        try:
                            conn = get_db_connection()
                            cursor = conn.cursor(dictionary=True)
                            cursor.execute("SELECT you_tube_id FROM videos WHERE id = %s", (response_data.get("video_id"),))
                            video_result = cursor.fetchone()
                            if video_result:
                                youtube_id = video_result['you_tube_id']
                            cursor.close()
                            conn.close()
                        except Exception as e:
                            print(f"获取YouTube ID失败: {e}")
                    
                    return ChatResponse(
                        answer=response_data.get("answer", content),
                        video_id=response_data.get("video_id"),
                        youtube_id=youtube_id,
                        start_time=response_data.get("start_time"),
                        end_time=response_data.get("end_time")
                    )
            except:
                pass
            
            # 如果无法解析JSON，返回纯文本回答
            return ChatResponse(answer=content)
            
        except Exception as e:
            return ChatResponse(answer=f"处理问题时出错: {str(e)}")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
