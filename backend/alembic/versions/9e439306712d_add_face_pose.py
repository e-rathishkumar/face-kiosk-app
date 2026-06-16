"""add_face_pose

Revision ID: 9e439306712d
Revises: 9f9004eee597
Create Date: 2026-06-10 11:37:24.686789

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = '9e439306712d'
down_revision: Union[str, Sequence[str], None] = '9f9004eee597'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


facepose_enum = sa.Enum(
    'FRONT',
    'LEFT',
    'RIGHT',
    'UP',
    'DOWN',
    'FRONT_LEFT',
    'FRONT_RIGHT',
    name='facepose'
)


def upgrade() -> None:
    facepose_enum.create(op.get_bind(), checkfirst=True)

    op.add_column(
        'employee_faces',
        sa.Column(
            'pose',
            facepose_enum,
            nullable=True
        )
    )


def downgrade() -> None:
    op.drop_column(
        'employee_faces',
        'pose'
    )

    facepose_enum.drop(
        op.get_bind(),
        checkfirst=True
    )
