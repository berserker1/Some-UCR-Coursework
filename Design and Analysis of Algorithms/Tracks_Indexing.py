

import pandas as pd
import lucene
import json
import os
from java.io import StringReader
from java.nio.file import Paths
from org.apache.lucene.analysis.standard import StandardAnalyzer
from org.apache.lucene.store import SimpleFSDirectory, NIOFSDirectory
from org.apache.lucene.index import IndexWriter, IndexWriterConfig, DirectoryReader
from org.apache.lucene.document import StringField, Document, TextField, Field
from org.apache.lucene.search import IndexSearcher, BooleanQuery
from org.apache.lucene.queryparser.classic import QueryParser
from org.apache.lucene.search import BooleanClause
import time
import matplotlib.pyplot as plt


def create_index(dir, data, data_type='tracks',mode='create'):
    if not os.path.exists(dir):
        os.mkdir(dir)

    st = time.time()
    # lucene.initVM(vmargs=['-Djava.awt.headless=true'])
    store = SimpleFSDirectory(Paths.get(dir))
    analyzer = StandardAnalyzer()
    config = IndexWriterConfig(analyzer)
    if mode == 'create':
        config.setOpenMode(IndexWriterConfig.OpenMode.CREATE)
    elif mode == 'append':
        config.setOpenMode(IndexWriterConfig.OpenMode.APPEND)

    writer = IndexWriter(store, config)
    x = []
    y = []

    queue = [n for n in data]
    i = 0

    if data_type == 'tracks':
        while queue:
            entry = queue.pop()
            if isinstance(entry,list):
                queue.extend([child for child in entry])
                continue
            if not isinstance(entry,dict):
                continue
            if not 'track_info' in entry:
                queue.extend([child for child in entry.values()])
                continue

            track_info = entry['track_info']
            i += 1

            print(i,str(track_info)[:100])
            print('================')

            doc = Document()
            doc.add(StringField("TrackID", str(i), Field.Store.YES))
            if 'artists' in track_info and track_info['artists']:
                doc.add(TextField("Artists", track_info['artists'][0]['name'], Field.Store.YES))
            if 'album' in track_info and 'name' in track_info['album']:
                doc.add(TextField("AlbumName", track_info['album']['name'], Field.Store.YES))

                    # Add track name
            if 'name' in track_info:
                doc.add(TextField("name", track_info['name'], Field.Store.YES))

            # Add release date
            if 'album' in track_info and 'release_date' in track_info['album']:
                doc.add(StringField("ReleaseDate", track_info['album']['release_date'], Field.Store.YES))

            # Add total tracks
            if 'album' in track_info and 'total_tracks' in track_info['album']:
                doc.add(StringField("TotalTracks", str(track_info['album']['total_tracks']), Field.Store.YES))


            # Add other fields as needed
            writer.addDocument(doc)

            elapsed_time = time.time() - st
            en = time.time()
            x.append(i)
            x.append(i)
            y.append(elapsed_time)
            y.append(en - st)

    elif data_type == 'artists':
        while queue:
            entry = queue.pop()
            if isinstance(entry,list):
                queue.extend([child for child in entry])
                continue
            if not isinstance(entry,dict):
                continue
            if not 'name' in entry:
                queue.extend([child for child in entry.values()])
                continue

            doc = Document()
            if 'followers' in entry and 'total' in entry['followers']:
                doc.add(TextField("followers", str(entry['followers']['total']), Field.Store.YES))
            if 'name' in entry:
                doc.add(TextField("name", entry['name'], Field.Store.YES))
            if 'popularity' in entry:
                doc.add(TextField("popularity", str(entry['popularity']), Field.Store.YES))
            writer.addDocument(doc)

            elapsed_time = time.time() - st
            en = time.time()
            x.append(i)
            x.append(i)
            y.append(elapsed_time)
            y.append(en - st)
    else:
        exit(1)

    writer.close()

    print('total num tracks:',i)

    plt.plot(x, y)
    plt.xlabel("Number of Tracks")
    plt.ylabel("Run time (in seconds)")
    plt.savefig("graph.png")

def retrieve(storedir, query):
    searchDir = NIOFSDirectory(Paths.get(storedir))
    searcher = IndexSearcher(DirectoryReader.open(searchDir))

    # Individual QueryParsers for each field
    artist_parser = QueryParser("Artists", StandardAnalyzer())
    album_parser = QueryParser("AlbumName", StandardAnalyzer())
    name_parser = QueryParser("name", StandardAnalyzer())

    # Combine queries for different fields using BooleanQuery
    boolean_query = BooleanQuery.Builder()
    boolean_query.add(artist_parser.parse(query), BooleanClause.Occur.SHOULD)
    boolean_query.add(album_parser.parse(query), BooleanClause.Occur.SHOULD)
    boolean_query.add(name_parser.parse(query), BooleanClause.Occur.SHOULD)

    parsed_query = boolean_query.build()

    topDocs = searcher.search(parsed_query, 10).scoreDocs

    topkdocs = []

    for hit in topDocs:
        doc = searcher.doc(hit.doc)
        topkdocs.append({
            "score": hit.score,
            "ID": doc.get("TrackID"),
            "Artists": doc.get("Artists"),
            "AlbumName": doc.get("AlbumName"),
            "name": doc.get("name"),
            "ReleaseDate": doc.get("ReleaseDate"),
            "TotalTracks": doc.get("TotalTracks")
        })

    print(len(topkdocs))
    print(topkdocs)
    return topkdocs

def all_artists_index(dir, data):
    if not os.path.exists(dir):
        os.mkdir(dir)

    st = time.time()
    lucene.initVM(vmargs=['-Djava.awt.headless=true'])
    store = SimpleFSDirectory(Paths.get(dir))
    analyzer = StandardAnalyzer()
    config = IndexWriterConfig(analyzer)
    config.setOpenMode(IndexWriterConfig.OpenMode.CREATE)

    writer = IndexWriter(store, config)
    x = []
    y = []

    queue = [n for n in data]
    i = 0

    while queue:
        entry = queue.pop()
        if not isinstance(entry,dict):
            continue
# Replace the 'your_dataset.json' with the actual path to your Spotify dataset in JSON format
if __name__ == "__main__":
    spotify_data = []
    artist_data = []
    artist_file = "all_artists.json"
    files = ['part1.json', 'part2.json', 'part3.json', 'part4.json']
    for elem in files:
        with open(elem, 'r') as file:
            output = json.load(file)
            print('length is ', len(output))
            spotify_data = spotify_data + output

    with open(artist_file, 'r') as file:
        artist_data = json.load(file)

    lucene.initVM(vmargs=['-Djava.awt.headless=true'])

    print('length of total is ', len(spotify_data))
    create_index('Spotify_Index/', spotify_data)
    create_index('Spotify_Index/', artist_data, data_type='artists', mode='append')
    first_name='Post Malone'
    posts = retrieve('Spotify_Index/',first_name)
    print(posts)