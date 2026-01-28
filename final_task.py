import json
import sys
import argparse
import re
from typing import Dict, List


STOPWORDS = {
    "the", "a", "an", "and", "or", "is", "are", "was", "were",
    "in", "on", "at", "to", "from", "by", "with", "of", "for",
    "this", "that", "these", "those", "it", "as", "be", "has",
    "have", "had", "but", "not"
}


def tokenize(text: str) -> List[str]:
    words = re.findall(r"[a-z]+", text.lower())
    return [w for w in words if w not in STOPWORDS]


def load_doc(file_path: str) -> Dict[int, str]:
    docs = {}
    with open(file_path, "r", encoding="utf-8") as f:
        for line in f:
            doc_id, text = line.rstrip("\n").split("\t", 1)
            docs[int(doc_id)] = text
    return docs


class InvertedIndex:
    def __init__(self):
        self.index = {}

    def build(self, docs: Dict[int, str]) -> None:
        for doc_id, text in docs.items():
            for word in tokenize(text):
                self.index.setdefault(word, set()).add(doc_id)

    def query(self, words: List[str]) -> List[int]:
        words = [w.lower() for w in words if w.lower() not in STOPWORDS]

        if not words:
            return []

        result = None
        for word in words:
            docs = self.index.get(word, set())
            result = docs if result is None else result & docs

        return sorted(result) if result else []

    def dump(self, file_path: str) -> None:
        with open(file_path, "w", encoding="utf-8") as f:
            json.dump({k: sorted(v) for k, v in self.index.items()}, f)

    @classmethod
    def load(cls, file_path: str) -> "InvertedIndex":
        with open(file_path, "r", encoding="utf-8") as f:
            raw = json.load(f)

        idx = cls()
        idx.index = {k: set(v) for k, v in raw.items()}
        return idx


# ---------- REQUIRED BY PYTEST ----------

def process_build(dataset: str, output: str) -> None:
    docs = load_doc(dataset)
    index = InvertedIndex()
    index.build(docs)
    index.dump(output)


def process_query(queries, index: str) -> None:
    idx = InvertedIndex.load(index)

    if hasattr(queries, "read"):
        words = queries.read().split()
    else:
        words = queries

    result = idx.query(words)
    print(" ".join(map(str, result)))


def setup_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="command", required=True)

    build_parser = subparsers.add_parser("build")
    build_parser.add_argument("--dataset", required=True)
    build_parser.add_argument("--output", required=True)

    query_parser = subparsers.add_parser("query")
    query_parser.add_argument("--index", default="inverted.index")
    query_parser.add_argument("--query", nargs="*")
    query_parser.add_argument("--from_file")

    return parser


def main():
    parser = setup_parser()
    args = parser.parse_args()

    if args.command == "build":
        process_build(
            dataset=args.dataset,
            output=args.output,
        )

    elif args.command == "query":
        if args.from_file:
            with open(args.from_file, "r", encoding="utf-8") as f:
                process_query(f, args.index)
        else:
            process_query(args.query or [], args.index)


if __name__ == "__main__":
    main()
