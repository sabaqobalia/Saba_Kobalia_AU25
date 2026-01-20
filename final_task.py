import json
import sys
import argparse


def load_doc(file_path):
    docs = {}
    with open(file_path, "r") as f:
        for line in f:
            doc_id, text = line.strip().split("\t", 1)
            docs[int(doc_id)] = text.lower()
    return docs


class InvertedIndex:
    def __init__(self):
        self.index = {}

    def build(self, docs):
        for doc_id, text in docs.items():
            for word in text.split():
                word = word.strip(".,!?()[]{}:;\"'").lower()
                if not word:
                    continue
                self.index.setdefault(word, set()).add(doc_id)

    def query(self, words):
        result = None
        for word in words:
            docs_with_word = self.index.get(word.lower(), set())
            if result is None:
                result = docs_with_word.copy()
            else:
                result &= docs_with_word
        return sorted(result) if result else []

    def dump(self, path):
        with open(path, "w") as f:
            json.dump({k: list(v) for k, v in self.index.items()}, f)

    @classmethod
    def load(cls, path):
        with open(path, "r") as f:
            raw = json.load(f)
        index = cls()
        index.index = {k: set(v) for k, v in raw.items()}
        return index


# ---------- REQUIRED BY PYTEST ----------

def process_build(dataset, output):
    docs = load_doc(dataset)
    index = InvertedIndex()
    index.build(docs)
    index.dump(output)


def process_query(queries, index):
    idx = InvertedIndex.load(index)

    if hasattr(queries, "read"):
        words = queries.read().split()
    else:
        words = queries

    result = idx.query(words)
    print(" ".join(map(str, result)))


def main():
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="command", required=True)

    query_parser = subparsers.add_parser("query")
    query_parser.add_argument("--query", nargs="*", default=[])

    args = parser.parse_args()

    if args.command == "query":
        process_query(
            queries=args.query,
            index="inverted.index",
        )
