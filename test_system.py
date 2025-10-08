#!/usr/bin/env python3
"""
YouTube 视频问答系统测试脚本
"""

import asyncio
import httpx
import json
import time

class SystemTester:
    def __init__(self):
        self.go_base_url = "http://localhost:8080"
        self.python_base_url = "http://localhost:8000"
    
    async def test_python_service(self):
        """测试Python服务"""
        print("🐍 测试Python服务...")
        
        try:
            async with httpx.AsyncClient() as client:
                # 测试健康检查
                response = await client.get(f"{self.python_base_url}/")
                if response.status_code == 200:
                    print("✅ Python服务运行正常")
                else:
                    print(f"❌ Python服务异常: {response.status_code}")
                    return False
                
                # 测试视频信息获取
                response = await client.get(f"{self.python_base_url}/video/Ylvr5hl6hYo")
                if response.status_code == 200:
                    video_info = response.json()
                    print(f"✅ 视频信息获取成功: {video_info['title']}")
                else:
                    print(f"❌ 视频信息获取失败: {response.status_code}")
                
                # 测试聊天功能
                chat_data = {"question": "这个视频主要讲了什么？"}
                response = await client.post(f"{self.python_base_url}/chat", json=chat_data)
                if response.status_code == 200:
                    chat_response = response.json()
                    print(f"✅ 聊天功能正常: {chat_response['answer'][:50]}...")
                else:
                    print(f"❌ 聊天功能异常: {response.status_code}")
                
                return True
                
        except Exception as e:
            print(f"❌ Python服务测试失败: {e}")
            return False
    
    async def test_go_service(self):
        """测试Go服务"""
        print("🚀 测试Go服务...")
        
        try:
            async with httpx.AsyncClient() as client:
                # 测试主页
                response = await client.get(f"{self.go_base_url}/")
                if response.status_code == 200:
                    print("✅ Go服务运行正常")
                else:
                    print(f"❌ Go服务异常: {response.status_code}")
                    return False
                
                # 测试视频列表API
                response = await client.get(f"{self.go_base_url}/api/videos")
                if response.status_code == 200:
                    result = response.json()
                    print(f"✅ 视频列表API正常: {result['code']}")
                else:
                    print(f"❌ 视频列表API异常: {response.status_code}")
                
                # 测试添加视频API
                video_data = {"youtube_url": "https://www.youtube.com/watch?v=Ylvr5hl6hYo"}
                response = await client.post(f"{self.go_base_url}/api/videos", json=video_data)
                if response.status_code == 200:
                    result = response.json()
                    print(f"✅ 添加视频API正常: {result['code']}")
                else:
                    print(f"❌ 添加视频API异常: {response.status_code}")
                
                # 测试聊天API
                chat_data = {"question": "这个视频主要讲了什么？"}
                response = await client.post(f"{self.go_base_url}/api/chat", json=chat_data)
                if response.status_code == 200:
                    result = response.json()
                    print(f"✅ 聊天API正常: {result['code']}")
                else:
                    print(f"❌ 聊天API异常: {response.status_code}")
                
                return True
                
        except Exception as e:
            print(f"❌ Go服务测试失败: {e}")
            return False
    
    async def test_integration(self):
        """测试系统集成"""
        print("🔗 测试系统集成...")
        
        try:
            async with httpx.AsyncClient() as client:
                # 测试完整的问答流程
                chat_data = {"question": "视频库中有哪些视频？"}
                response = await client.post(f"{self.go_base_url}/api/chat", json=chat_data)
                
                if response.status_code == 200:
                    result = response.json()
                    print(f"✅ 集成测试成功: {result['data']['answer'][:50]}...")
                    return True
                else:
                    print(f"❌ 集成测试失败: {response.status_code}")
                    return False
                    
        except Exception as e:
            print(f"❌ 集成测试失败: {e}")
            return False
    
    async def run_all_tests(self):
        """运行所有测试"""
        print("🧪 开始系统测试...")
        print("=" * 50)
        
        # 等待服务启动
        print("⏳ 等待服务启动...")
        await asyncio.sleep(5)
        
        # 测试Python服务
        python_ok = await self.test_python_service()
        print()
        
        # 测试Go服务
        go_ok = await self.test_go_service()
        print()
        
        # 测试集成
        integration_ok = await self.test_integration()
        print()
        
        # 输出测试结果
        print("=" * 50)
        print("📊 测试结果:")
        print(f"Python服务: {'✅ 通过' if python_ok else '❌ 失败'}")
        print(f"Go服务: {'✅ 通过' if go_ok else '❌ 失败'}")
        print(f"系统集成: {'✅ 通过' if integration_ok else '❌ 失败'}")
        
        if python_ok and go_ok and integration_ok:
            print("\n🎉 所有测试通过！系统运行正常！")
            print("🌐 访问地址: http://localhost:8080")
        else:
            print("\n⚠️  部分测试失败，请检查服务状态")
        
        return python_ok and go_ok and integration_ok

async def main():
    tester = SystemTester()
    await tester.run_all_tests()

if __name__ == "__main__":
    asyncio.run(main())
