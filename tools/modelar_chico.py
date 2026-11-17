"""Modela o Chico em 3D (baixo polígono) como peças rígidas com pivôs, e exporta assets/3d/chico.glb.

Braços e pernas ficam presos a pivôs vazios, nos ombros e quadris. O Godot gira esses pivôs
por código para fazer as animações (parado, andar, pular, cair, dano), sem depender de rig.

Uso (Blender em modo de linha de comando):
    "C:/Program Files/Blender Foundation/Blender 5.2/blender.exe" -b --python tools/modelar_chico.py

Convenção: o personagem olha para +X (direita, no jogo 2.5D). Altura de ~1,7 unidades (metros).
Pivôs: PivoBracoE, PivoBracoD, PivoPernaE, PivoPernaD.
"""
import os

import bpy

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SAIDA = os.path.join(RAIZ, "assets", "3d", "chico.glb")

OMBRO_E = (0, 0.15, 1.3)
OMBRO_D = (0, -0.15, 1.3)
QUADRIL_E = (0, 0.09, 0.92)
QUADRIL_D = (0, -0.09, 0.92)


def limpar_cena() -> None:
    bpy.ops.wm.read_factory_settings(use_empty=True)


def material(nome: str, cor: tuple) -> bpy.types.Material:
    mat = bpy.data.materials.new(nome)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (*cor, 1.0)
    bsdf.inputs["Roughness"].default_value = 0.85
    return mat


def cubo(nome, posicao, tamanho, mat):
    bpy.ops.mesh.primitive_cube_add(size=1, location=posicao)
    obj = bpy.context.active_object
    obj.name = nome
    obj.scale = tamanho
    obj.data.materials.append(mat)
    return obj


def cilindro(nome, posicao, raio, altura, mat):
    bpy.ops.mesh.primitive_cylinder_add(radius=raio, depth=altura, location=posicao)
    obj = bpy.context.active_object
    obj.name = nome
    obj.data.materials.append(mat)
    return obj


def esfera(nome, posicao, raio, mat):
    bpy.ops.mesh.primitive_uv_sphere_add(radius=raio, location=posicao, segments=12, ring_count=8)
    obj = bpy.context.active_object
    obj.name = nome
    obj.data.materials.append(mat)
    return obj


def pivo(nome, posicao):
    bpy.ops.object.empty_add(type="PLAIN_AXES", location=posicao, radius=0.05)
    obj = bpy.context.active_object
    obj.name = nome
    return obj


def prender(filho, pai):
    """Prende a peça ao pivô sem mudar a posição que ela tem na cena."""
    bpy.ops.object.select_all(action="DESELECT")
    filho.select_set(True)
    pai.select_set(True)
    bpy.context.view_layer.objects.active = pai
    bpy.ops.object.parent_set(type="OBJECT", keep_transform=True)


def montar():
    pele = material("Pele", (0.55, 0.36, 0.22))
    camisa = material("Camisa", (0.22, 0.42, 0.62))
    calca = material("Calca", (0.29, 0.22, 0.15))
    chapeu = material("Chapeu", (0.85, 0.7, 0.42))
    bota = material("Bota", (0.16, 0.12, 0.09))
    olho = material("Olho", (0.05, 0.04, 0.03))

    # Peças fixas: tronco, cintura, cabeça e chapéu.
    cubo("Tronco", (0, 0, 1.17), (0.3, 0.22, 0.4), camisa)
    cubo("Cintura", (0, 0, 0.94), (0.26, 0.2, 0.06), calca)
    esfera("Cabeca", (0, 0, 1.5), 0.14, pele)
    cilindro("ChapeuAba", (0, 0, 1.6), 0.25, 0.025, chapeu)
    cilindro("ChapeuCopa", (0, 0, 1.69), 0.13, 0.12, chapeu)
    cubo("OlhoE", (0.135, 0.05, 1.5), (0.01, 0.02, 0.02), olho)
    cubo("OlhoD", (0.135, -0.05, 1.5), (0.01, 0.02, 0.02), olho)

    # Braços: pivô no ombro, com a manga e a mão presas a ele.
    for lado, ombro in (("E", OMBRO_E), ("D", OMBRO_D)):
        piv = pivo("PivoBraco" + lado, ombro)
        manga = cilindro("Braco" + lado, (ombro[0], ombro[1], ombro[2] - 0.23), 0.06, 0.46, camisa)
        mao = esfera("Mao" + lado, (ombro[0], ombro[1], ombro[2] - 0.5), 0.065, pele)
        prender(manga, piv)
        prender(mao, piv)

    # Pernas: pivô no quadril, com a calça e a bota presas a ele.
    for lado, quadril in (("E", QUADRIL_E), ("D", QUADRIL_D)):
        piv = pivo("PivoPerna" + lado, quadril)
        perna = cilindro("Perna" + lado, (quadril[0], quadril[1], quadril[2] - 0.46), 0.085, 0.86, calca)
        bota_obj = cubo("Bota" + lado, (0.04, quadril[1], 0.04), (0.16, 0.1, 0.08), bota)
        prender(perna, piv)
        prender(bota_obj, piv)


def exportar():
    os.makedirs(os.path.dirname(SAIDA), exist_ok=True)
    bpy.ops.export_scene.gltf(filepath=SAIDA, export_format="GLB", export_animations=False, export_yup=True)
    print("exportado", SAIDA)


def main():
    limpar_cena()
    montar()
    exportar()


main()
