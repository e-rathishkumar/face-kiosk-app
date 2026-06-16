from sqlalchemy import text
from sqlalchemy.orm import Session


class FaceMatcher:

    @staticmethod
    def find_best_match(
        db: Session,
        embedding: list[float]
    ):
        query = text(
            """
            SELECT
                employee_id,
                pose,
                embedding <=> CAST(:embedding AS vector)
                    AS distance
            FROM employee_faces
            ORDER BY
                embedding <=> CAST(:embedding AS vector)
            LIMIT 1
            """
        )

        result = db.execute(
            query,
            {
                "embedding": str(
                    embedding
                )
            }
        ).fetchone()

        if not result:
            return None

        return result
