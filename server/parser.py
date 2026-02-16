from bs4 import BeautifulSoup
import requests
import re

# возвращает гороскоп для всех зз на сегодня
def getHoroTodayAll():
	"""
	Получает гороскоп на сегодня для всех знаков зодиака с сайта.
	"""
	headers = requests.utils.default_headers()
	headers.update({'User-Agent': 'Mozilla/5.0 (Windows; U; Windows NT 5.0) AppleWebKit/532.1.0 (KHTML, like Gecko) Chrome/34.0.822.0 Safari/532.1.0',})
	url = requests.get('https://horo.mail.ru/prediction/', headers=headers)
	s = BeautifulSoup(url.text, 'html.parser')
	title = s.find("h1", {"data-qa": "Title"}).getText()
	text = s.find("main", {"data-qa": "ArticleLayout"})
	if text:
		text_with_links_removed = re.sub(r'<a(.*?)</a>', '', str(text))
		cleaned_soup = BeautifulSoup(text_with_links_removed, 'html.parser')
		text = cleaned_soup.getText(separator=' ')
	else:
		text = "Гороскоп не найден."
	content = '<b>🗓 '+title+'</b>\n\n💬 '+text
	return content

# возвращает указнный гороскоп
def getHoro(char, date):
	"""
	Получает гороскоп для указанного знака зодиака и периода с сайта.
	"""
	headers = requests.utils.default_headers()
	headers.update({'User-Agent': 'Mozilla/5.0 (Windows; U; Windows NT 5.0) AppleWebKit/532.1.0 (KHTML, like Gecko) Chrome/34.0.822.0 Safari/532.1.0',})
	url = requests.get('https://horo.mail.ru/prediction/' + char + '/' + date + '/', headers=headers)
	s = BeautifulSoup(url.text, 'html.parser')
	title = s.find("h1", {"data-qa": "Title"}).getText()
	date = s.find("span", {"data-qa": "Text"}).getText()
	text_tag = s.find("main", {"data-qa": "ArticleLayout"})
	if text_tag:
		text_with_links_removed = re.sub(r'<a(.*?)</a>', '', str(text_tag))
		cleaned_soup = BeautifulSoup(text_with_links_removed, 'html.parser')
		text = cleaned_soup.getText(separator=' ')
	else:
		text = "Гороскоп не найден."
	content = '<b>🗓 '+title+'</b>\n\n💬 '+text
	return content