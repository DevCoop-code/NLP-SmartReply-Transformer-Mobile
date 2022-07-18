import os
import re				# for 정규표현식
import json

import numpy as np
import pandas as pd
from tqdm import tqdm   # 작업의 진행도를 표시

from konlpy.tag import Okt

FILTERS = "([~.,!?\"':;)(])"
PAD="<PAD>"			# 어떤 의미도 없는 패딩토큰
STD="<SOS>" 		# 시작 토근을 의미
END="<END>"			# 종료 토큰을 의미
UNK="<UNK>" 		# 사전에 없는 단어를 의미

PAD_INDEX=0
STD_INDEX=1
END_INDEX=2
UNK_INDEX=3

MARKER = [PAD, STD, END, UNK]
CHANGE_FILTER = re.compile(FILTERS)

MAX_SEQUENCE = 25

# 데이터를 판다를 통새 읽어옴
def load_data(path):
	data_df = pd.read_csv(path, header=0)
	question, answer = list(data_df['Q']), list(data_df['A'])

	return question, answer

# 단어 리스트 만들기
def data_tokenizer(data):
	words = []
	for sentence in data:
		sentence = re.sub(CHANGE_FILTER, "", str(sentence))  # 정규표현식을 사용하여 특수 기호를 모두 제거
		for word in sentence.split():
			words.append(word)
	return [word for word in words if word]

# 한글 텍스트를 토크나이징하기 위해 형태소로 분리
def prepro_like_morphlized(data):
	morph_analyzer = Okt()
	result_data = list()
	for seq in tqdm(data):
		morphlized_seq = " ".join(morph_analyzer.morphs(str(seq).replace(' ', '')))
		result_data.append(str(morphlized_seq))

	return result_data

# 단어 사전 만들기
def load_vocabulary(path, vocab_path, tokenize_as_morph=False):
	vocabulary_list = []

	if not os.path.exists(vocab_path):
		if (os.path.exists(path)):
			data_df = pd.read_csv(path, encoding='utf-8')
			question, answer = list(data_df['Q']), list(data_df['A'])
			if (tokenize_as_morph):   # 형태소에 따른 토크나이져 처리
				question = prepro_like_morphlized(question)
				answer = prepro_like_morphlized(answer)
			data = []
			data.extend(question)  # extend를 통해 구조가 없는 배열로 만듬
			data.extend(answer)

			words = data_tokenizer(data)
			words = list(set(words))  # set(): 중복 제거
			words[:0] = MARKER    # Tokenizing된 단어 리스트의 앞에 MARKER를 추가

		with open(vocab_path, 'w', encoding='utf-8') as vocabulary_file:
			for word in words:
				vocabulary_file.write(word + '\n')

	with open(vocab_path, 'r', encoding='utf-8') as vocabulary_file:
		for line in vocabulary_file:
			vocabulary_list.append(line.strip())  # strip(): 양옆의 공백 제거

	# char2idx: 단어에 대한 인덱스 (Dictionary Type)
	# idx2char: 인덱스에 대한 단어 (Dictionary Type)
	char2idx, idx2char = make_vocabulary(vocabulary_list)

	return char2idx, idx2char, len(char2idx)

def make_vocabulary(vocabulary_list):
	# 리스트를 키가 단어이고 값이 인덱스인 딕셔너리를 만듬
	char2idx = {char:idx for idx, char in enumerate(vocabulary_list)}   # enumerate: index와 원소로 이뤄진 tuple을 생성 Ex] (0, 'A') (1, 'B')

	# 키가 인덱스이고 값이 단어인 딕셔너리를 만듬
	idx2char = {idx: char for idx, char in enumerate(vocabulary_list)}

	return char2idx, idx2char



# Encoder 전처리 함수
def enc_processing(value, dictionary, tokenize_as_morph=False):
	sequences_input_index = []
	sequences_length = []

	if tokenize_as_morph:
		value = prepro_like_morphlized(value)

	for sequence in value:
		sequence = re.sub(CHANGE_FILTER, "", str(sequence))
		sequence_index = []

		for word in sequence.split():
			if dictionary.get(word) is not None:
				sequence_index.extend([dictionary[word]])
			else:
				sequence_index.extend([dictionary[UNK]])

		if len(sequence_index) > MAX_SEQUENCE:
			sequence_index = sequence_index[:MAX_SEQUENCE]

		sequences_length.append(len(sequence_index))
		sequence_index += (MAX_SEQUENCE - len(sequence_index)) * [dictionary[PAD]]  # 최대 길이보다 짧은 단어는 최대 길이만큼 모두 패드로 채움

		sequences_input_index.append(sequence_index)

	return np.asarray(sequences_input_index), sequences_length   # 전처리한 데이터와, 패딩 처리하기 전의 각 문장의 실제 길이를 담고 있는 리스트를 리턴



# Decoder 전처리 함수
## Decoder의 입력으로 사용될 입력값을 만드는 전처리 함수
## Decoder의 결과로 핛습을 위해 필요한 라벨인 타깃값을 만드는 전처리 함수

### Ex] 그래 오랜만이야 ==> 디코더 입력값: <SOS>, 그래, 오랜만이야, <PAD>    /   디코더 타깃값: 그래, 오랜만이야, <END>, <PAD>

# Decoder의 입력값 만드는 함수
def dec_output_processing(value, dictionary, tokenize_as_morph=False):
	sequences_output_index = []
	sequences_length = []

	if tokenize_as_morph:
		value = prepro_like_morphlized(value)
	for sequence in value:
		sequence = re.sub(CHANGE_FILTER, "", str(sequence))
		sequence_index = []
		sequence_index = [dictionary[STD]] + [dictionary[word] if word in dictionary else dictionary[UNK] for word in sequence.split()]

		if len(sequence_index) > MAX_SEQUENCE:
			sequence_index = sequence_index[:MAX_SEQUENCE]
		sequences_length.append(len(sequence_index))
		sequence_index += (MAX_SEQUENCE - len(sequence_index)) * [dictionary[PAD]]

		sequences_output_index.append(sequence_index)

	return np.asarray(sequences_output_index), sequences_length

# Decoder의 Target 값을 만드는 함수
def dec_target_processing(value, dictionary, tokenize_as_morph=False):
	sequence_target_index = []

	if tokenize_as_morph:
		value = prepro_like_morphlized(value)

	for sequence in value:
		sequence = re.sub(CHANGE_FILTER, "", str(sequence))
		sequence_index = [dictionary[word] if word in dictionary else dictionary[UNK] for word in sequence.split()]
		if len(sequence_index) >= MAX_SEQUENCE:
			sequence_index = sequence_index[:MAX_SEQUENCE - 1] + [dictionary[END]]
		else:
			sequence_index += [dictionary[END]]

		sequence_index += (MAX_SEQUENCE - len(sequence_index)) * [dictionary[PAD]]
		sequence_target_index.append(sequence_index)

	return np.asarray(sequence_target_index)






