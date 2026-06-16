from alembic import op
import sqlalchemy as sa
from pgvector.sqlalchemy import Vector


# revision identifiers
revision = "299000097b24"
down_revision = "9e439306712d"
branch_labels = None
depends_on = None


def upgrade():
    op.execute(
        """
        ALTER TABLE employee_faces
        ALTER COLUMN embedding
        TYPE vector(512)
        USING embedding::vector;
        """
    )


def downgrade():
    op.execute(
        """
        ALTER TABLE employee_faces
        ALTER COLUMN embedding
        TYPE double precision[]
        USING embedding::double precision[];
        """
    )
